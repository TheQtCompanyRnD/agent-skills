#!/usr/bin/env python3
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
"""Parse a qmlprofiler .qtd trace file and output a JSON summary of hotspots."""

import json
import sys
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict


# cacheEventType values, from QQmlProfilerDefinitions::PixmapEventType in
# qtdeclarative/src/qml/debugger/qqmlprofilerdefinitions_p.h.
PIXMAP_SIZE_KNOWN = "0"
PIXMAP_REFERENCE_COUNT_CHANGED = "1"
PIXMAP_CACHE_COUNT_CHANGED = "2"
PIXMAP_LOADING_STARTED = "3"
PIXMAP_LOADING_FINISHED = "4"
PIXMAP_LOADING_ERROR = "5"


# ----- Phase 1: parse XML into typed event lists --------------------------

def _parse_event_definitions(event_data):
    """Build the eventIndex -> definition lookup from <eventData>."""
    event_defs = {}
    for ev in event_data:
        idx = int(ev.get("index"))
        event_defs[idx] = {
            "name": ev.findtext("displayname", ""),
            "type": ev.findtext("type", ""),
            "filename": ev.findtext("filename", ""),
            "line": ev.findtext("line", ""),
            "details": ev.findtext("details", ""),
            "memoryEventType": ev.findtext("memoryEventType", ""),
            "cacheEventType": ev.findtext("cacheEventType", ""),
            "animationFrame": ev.findtext("animationFrame", ""),
        }
    return event_defs


def _extract_events(root, event_defs):
    """Walk <profilerDataModel> ranges and split into typed lists.

    Returns a 5-tuple ``(ranges, memory_events, pixmap_events,
    animation_events, quick3d_dropped)``. Quick3D events are not
    extracted (this skill targets 2D Qt Quick) but are counted, so the
    report can state that 3D costs are missing rather than leaving the
    reader to assume the trace covered everything. Range events with
    zero duration are dropped.
    """
    ranges = []
    memory_events = []
    pixmap_events = []
    animation_events = []
    quick3d_dropped = 0

    for section in root:
        if section.tag != "profilerDataModel":
            continue
        for rng in section:
            if rng.tag != "range":
                continue
            ev_idx = int(rng.get("eventIndex", -1))
            if ev_idx not in event_defs:
                continue
            ed = event_defs[ev_idx]

            if ed["type"] == "MemoryAllocation":
                memory_events.append({
                    "amount_bytes": int(rng.get("amount", 0)),
                    "memoryEventType": ed["memoryEventType"],
                    "start_time": int(rng.get("startTime", 0)),
                })
            elif ed["type"] == "PixmapCache":
                pixmap_events.append({
                    "filename": ed["filename"],
                    "cacheEventType": ed["cacheEventType"],
                    "width": int(rng.get("width", 0)),
                    "height": int(rng.get("height", 0)),
                })
            elif ed["type"] == "Event" and ed["animationFrame"]:
                animation_events.append({
                    "framerate": int(rng.get("framerate", 0)),
                    "animationcount": int(rng.get("animationcount", 0)),
                })
            elif ed["type"].startswith("Quick3D"):
                # Out of scope: this skill targets 2D Qt Quick. Counted so
                # the report can flag that 3D costs are unaccounted for.
                quick3d_dropped += 1
                continue
            else:
                duration = int(rng.get("duration", 0))
                if duration > 0:
                    ranges.append({
                        "duration_ns": duration,
                        "type": ed["type"],
                        "filename": ed["filename"],
                        "line": ed["line"],
                        "name": ed["name"],
                        "details": ed["details"],
                    })

    return (ranges, memory_events, pixmap_events, animation_events,
            quick3d_dropped)


# ----- Phase 2: summarize event lists into category summaries --------------

def _aggregate_hotspots(ranges):
    """Aggregate range events by (filename, line, type), sorted desc."""
    by_loc = defaultdict(lambda: {"count": 0, "total_ns": 0})
    for r in ranges:
        key = f"{r['filename']}:{r['line']}|{r['type']}"
        by_loc[key]["count"] += 1
        by_loc[key]["total_ns"] += r["duration_ns"]
        by_loc[key]["filename"] = r["filename"]
        by_loc[key]["line"] = r["line"]
        by_loc[key]["type"] = r["type"]
        by_loc[key]["name"] = r["name"]
        by_loc[key]["details"] = r["details"]
    return sorted(by_loc.values(), key=lambda x: -x["total_ns"])


def _summarize_types(ranges):
    """Aggregate range events by type, sorted desc by total_ns."""
    by_type = defaultdict(lambda: {"count": 0, "total_ns": 0})
    for r in ranges:
        by_type[r["type"]]["count"] += 1
        by_type[r["type"]]["total_ns"] += r["duration_ns"]
    return [
        {
            "type": t,
            "count": v["count"],
            "total_ms": round(v["total_ns"] / 1e6, 2),
        }
        for t, v in sorted(by_type.items(), key=lambda x: -x[1]["total_ns"])
    ]


def _summarize_memory_category(events):
    """Roll up alloc/free events for a single memory category."""
    events_sorted = sorted(events, key=lambda e: e["start_time"])
    alloc_bytes = sum(e["amount_bytes"] for e in events_sorted
                      if e["amount_bytes"] > 0)
    freed_bytes = -sum(e["amount_bytes"] for e in events_sorted
                       if e["amount_bytes"] < 0)
    alloc_count = sum(1 for e in events_sorted
                      if e["amount_bytes"] > 0)
    running = 0
    peak = 0
    for e in events_sorted:
        running += e["amount_bytes"]
        if running > peak:
            peak = running
    return {
        "alloc_count": alloc_count,
        "alloc_bytes": alloc_bytes,
        "freed_bytes": freed_bytes,
        "peak_live_bytes": peak,
        "final_live_bytes": running,
    }


def _summarize_memory(memory_events):
    """Memory summary keyed by QV4::Profiling::MemoryType.

    Qt's enum values: 0=HeapPage, 1=LargeItem, 2=SmallItem. Each range
    carries a signed ``amount`` -- positive for allocation, negative for
    free -- so per-category live bytes are tracked as a running sum in
    chronological (startTime) order, not as max(amount).
    """
    heap_pages = _summarize_memory_category(
        [e for e in memory_events if e["memoryEventType"] == "0"])
    large_items = _summarize_memory_category(
        [e for e in memory_events if e["memoryEventType"] == "1"])
    small_items = _summarize_memory_category(
        [e for e in memory_events if e["memoryEventType"] == "2"])

    return {
        "heap_pages": heap_pages,
        "large_items": large_items,
        "small_items": small_items,
        "total_allocations": (small_items["alloc_count"]
                              + large_items["alloc_count"]),
        "total_allocated_bytes": (small_items["alloc_bytes"]
                                  + large_items["alloc_bytes"]),
        "peak_heap_bytes": heap_pages["peak_live_bytes"],
    }


def _summarize_animations(animation_events):
    """Animation frame-time percentiles and wall-clock estimate.

    Frame times are quantised (``1000 / framerate`` on integer samples),
    so frames tie at the percentile: ``frames_ge_*`` are counted, not
    derived as 5% / 1% of ``frame_count``.

    Returns ``(animations_dict, wall_ms_est)``, or ``(None, None)`` if
    no positive framerate samples are available.
    """
    framerates = [e["framerate"] for e in animation_events if e["framerate"] > 0]
    if not framerates:
        return None, None

    n = len(framerates)
    # Rounded once so the percentiles and frames_ge_* compare on identical
    # values. frames_over_* compare raw against fixed thresholds; with
    # integer framerates the two forms never differ.
    frame_ms = sorted(round(1000.0 / f, 2) for f in framerates)

    def pct(p):
        idx = min(n - 1, max(0, int(round(p * (n - 1)))))
        return frame_ms[idx]

    p95, p99 = pct(0.95), pct(0.99)
    avg_fps = sum(framerates) / n
    wall_ms_est = round(n / max(avg_fps, 0.001) * 1000.0, 0)

    animations = {
        "frame_count": n,
        "frame_ms_p50": pct(0.50),
        "frame_ms_p95": p95,
        "frame_ms_p99": p99,
        "frames_ge_p95": sum(1 for x in frame_ms if x >= p95),
        "frames_ge_p99": sum(1 for x in frame_ms if x >= p99),
        "distinct_frame_ms": len(set(frame_ms)),
        "frame_ms_max": frame_ms[-1],
        "frames_over_25ms": sum(1 for f in framerates if 1000.0 / f > 25),
        "frames_over_33ms": sum(1 for f in framerates if 1000.0 / f > 33),
        "frames_over_50ms": sum(1 for f in framerates if 1000.0 / f > 50),
        "avg_framerate": round(avg_fps, 1),
        "min_framerate": min(framerates),
        "max_framerate": max(framerates),
    }
    return animations, wall_ms_est


def _summarize_pixmap_cache(pixmap_events):
    """Pixmap cache summary and failed-load breakdown.

    ``unaccounted`` is ``load_requests - loaded - failed``, signed:
    positive for loads still in flight when the app exited, negative for
    loads that resolved but whose LoadingStarted predates the trace
    window (recording began late, or attached to a running app).
    SizeKnown is the only event carrying width/height, so the pixmap
    dimension list is built from it.

    ``cache_count_changes`` is not an eviction count: CacheCountChanged
    fires on insertion as well as removal, and the cache size that would
    separate the two is always 0 in a .qtd file (QTBUG-148750). Do not
    derive a split from ``refCount``.

    Returns ``(pixmap_cache, pixmap_errors)``; ``pixmap_errors`` is
    ``None`` when every load succeeded.
    """
    sized = [e for e in pixmap_events
             if e["cacheEventType"] == PIXMAP_SIZE_KNOWN]
    requests = [e for e in pixmap_events
                if e["cacheEventType"] == PIXMAP_LOADING_STARTED]
    finished = [e for e in pixmap_events
                if e["cacheEventType"] == PIXMAP_LOADING_FINISHED]
    errors = [e for e in pixmap_events
              if e["cacheEventType"] == PIXMAP_LOADING_ERROR]
    cache_changes = [e for e in pixmap_events
                     if e["cacheEventType"] == PIXMAP_CACHE_COUNT_CHANGED]

    pixmap_list = [
        {
            "filename": e["filename"],
            "width": e["width"],
            "height": e["height"],
            "pixels": e["width"] * e["height"],
        }
        for e in sized
    ]
    pixmap_list.sort(key=lambda x: -x["pixels"])

    pixmap_cache = {
        "load_requests": len(requests),
        "loaded": len(finished),
        "failed": len(errors),
        "unaccounted": len(requests) - len(finished) - len(errors),
        "cache_count_changes": len(cache_changes),
        "pixmaps": pixmap_list,
    }

    if not errors:
        return pixmap_cache, None

    by_url = Counter(e["filename"] for e in errors)
    pixmap_errors = {
        "total": len(errors),
        "distinct_urls": len(by_url),
        "by_url": [
            {"filename": f, "count": c}
            for f, c in sorted(by_url.items(), key=lambda kv: (-kv[1], kv[0]))
        ],
    }
    return pixmap_cache, pixmap_errors


# ----- Phase 3: format / evaluate ------------------------------------------

def _format_hotspots(hotspots, top_n=30):
    """Pick top-N hotspots and round timings for output."""
    return [
        {
            "filename": h["filename"],
            "line": int(h["line"]) if h["line"] else 0,
            "type": h["type"],
            "name": h["name"],
            "details": h.get("details", ""),
            "count": h["count"],
            "total_ms": round(h["total_ns"] / 1e6, 2),
            "avg_ms": round(h["total_ns"] / h["count"] / 1e6, 3),
        }
        for h in hotspots[:top_n]
    ]


def _attach_per_frame_metrics(type_summary, formatted_hotspots, frame_count):
    """Add ``ms_per_frame`` to each entry in-place."""
    for t in type_summary:
        t["ms_per_frame"] = round(t["total_ms"] / frame_count, 3)
    for h in formatted_hotspots:
        h["ms_per_frame"] = round(h["total_ms"] / frame_count, 3)


# ----- Master --------------------------------------------------------------

def parse_trace(path):
    try:
        tree = ET.parse(path)
    except ET.ParseError as e:
        return {"error": f"Failed to parse trace file: {e}"}
    except FileNotFoundError:
        return {"error": f"Trace file not found: {path}"}
    root = tree.getroot()

    event_data = root.find("eventData")
    if event_data is None:
        return {"error": "No eventData found in trace"}

    event_defs = _parse_event_definitions(event_data)
    (ranges, memory_events, pixmap_events, animation_events,
     quick3d_dropped) = _extract_events(root, event_defs)

    if not (ranges or memory_events or pixmap_events or animation_events):
        if quick3d_dropped:
            return {"error": "Trace contains only Qt Quick 3D events "
                             f"({quick3d_dropped}); this tool covers 2D "
                             "Qt Quick only"}
        return {"error": "No events found in trace"}

    hotspots = _aggregate_hotspots(ranges)
    type_summary = _summarize_types(ranges)
    formatted_hotspots = _format_hotspots(hotspots)

    range_events_total_ms = round(
        sum(r["duration_ns"] for r in ranges) / 1e6, 2)

    result = {
        "range_events_total_ms": range_events_total_ms,
        "total_events": (
            len(ranges)
            + len(memory_events)
            + len(pixmap_events)
            + len(animation_events)
        ),
        "by_type": type_summary,
        "hotspots": formatted_hotspots,
    }

    if quick3d_dropped:
        result["quick3d_events_dropped"] = quick3d_dropped

    if memory_events:
        result["memory"] = _summarize_memory(memory_events)

    if animation_events:
        animations, wall_ms_est = _summarize_animations(animation_events)
        if animations is not None:
            result["wall_ms_est"] = wall_ms_est
            result["animations"] = animations
            _attach_per_frame_metrics(
                type_summary, formatted_hotspots, animations["frame_count"])

    if pixmap_events:
        pixmap_cache, pixmap_errors = _summarize_pixmap_cache(pixmap_events)
        result["pixmap_cache"] = pixmap_cache
        if pixmap_errors is not None:
            result["pixmap_errors"] = pixmap_errors

    return result


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <trace.qtd>", file=sys.stderr)
        sys.exit(1)

    result = parse_trace(sys.argv[1])
    json.dump(result, sys.stdout, indent=2)
    print()

    if "error" in result:
        sys.exit(1)


if __name__ == "__main__":
    main()
