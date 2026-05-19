// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T

import Qt.Fonts as Fonts

T.Control {
    id: control

    property int siblingCount: 1
    property int boundaryCount: 1

    property int count: 0
    property int currentIndex: 0

    signal previousPressed()
    signal nextPressed()
    signal itemPressed(idx: int)

    property int appearanceVariant: PaginationNumberStyle.AppearanceVariant.Default
    property int typeVariant: PaginationNumberStyle.TypeVariant.Primary
    property int sizeVariant: PaginationNumberStyle.SizeVariant.Medium

    property PaginationNumberStyle.Type _type: {
        switch (control.typeVariant) {
            case PaginationNumberStyle.TypeVariant.Primary: return PaginationNumberStyle.primary

            default: return PaginationNumberStyle.primary
        }
    }

    property PaginationNumberStyle.Size _size: {
        switch (control.sizeVariant) {
            case PaginationNumberStyle.SizeVariant.Small: return PaginationNumberStyle.small
            case PaginationNumberStyle.SizeVariant.Medium: return PaginationNumberStyle.medium
            case PaginationNumberStyle.SizeVariant.Large: return PaginationNumberStyle.large

            default: return PaginationNumberStyle.medium
        }
    }

    property bool _outline: control.appearanceVariant === PaginationNumberStyle.AppearanceVariant.Outline

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 0
    spacing: control._size.spacing

    contentItem: Row {
        spacing: control.spacing

        IconButton {
            id: prev
            iconGlyph: Fonts.FontInterface.icons.arrow_left_16
            sizeVariant: {
                switch (control.sizeVariant) {
                    case PaginationNumberStyle.SizeVariant.Small: return IconButtonStyle.SizeVariant.Small16
                    case PaginationNumberStyle.SizeVariant.Medium: return IconButtonStyle.SizeVariant.Medium16
                    case PaginationNumberStyle.SizeVariant.Large: return IconButtonStyle.SizeVariant.Large16

                    default: return IconButtonStyle.SizeVariant.Medium16
                }
            }
            appearanceVariant: control._outline ? IconButtonStyle.AppearanceVariant.Outline
                                                : IconButtonStyle.AppearanceVariant.Default

            enabled: control.currentIndex > 0

            onPressed: control.previousPressed()
        }

        Repeater {
            model: control.getPaginationRange(control.count,
                                              control.currentIndex,
                                              control.siblingCount,
                                              control.boundaryCount)
            delegate: Rectangle {
                id: label

                required property int index
                required property var modelData

                radius: control._size.radius
                color: label._style.background
                border {
                    color: label._style.border
                    width: control._outline ? control._size.borderWidth : 0
                }

                width: Math.max(text.lineHeight + control._size.horizontalPadding * 2,
                                text.contentWidth + control._size.horizontalPadding * 2)
                height: Math.max(text.lineHeight + control._size.verticalPadding * 2,
                                 text.contentHeight + control._size.verticalPadding * 2)

                HoverHandler {
                    id: hoverHandler
                    enabled: !label.modelData.isEllipsis
                }

                TapHandler {
                    id: tapHandler
                    enabled: !label.modelData.isEllipsis
                    onTapped: control.itemPressed(label.modelData.page)
                }

                property PaginationNumberStyle.StateStyle _style: {
                    // TODO: Special case should be handled differently
                    if (label.modelData.isEllipsis)
                        return control._type.disable

                    let active = (label.modelData.page === control.currentIndex)

                    if (control.enabled && !hoverHandler.hovered && !active)
                        return control._type.idle
                    else if (control.enabled && hoverHandler.hovered && !active)
                        return control._type.hover
                    else if (control.enabled && !hoverHandler.hovered && active)
                        return control._type.active
                    else if (control.enabled && hoverHandler.hovered && active)
                        return control._type.activeHover
                    else if (!control.enabled)
                        return control._type.disable

                    return control._type.idle
                }

                Text {
                    id: text
                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: label.modelData.isEllipsis ? "..." : label.modelData.page + 1

                    color: label._style.text
                    lineHeightMode: Text.FixedHeight
                    lineHeight: control._size.lineHeight

                    font {
                        family: Fonts.FontInterface.interFont.font.family
                        pixelSize: control._size.fontSize
                        variableAxes: {
                            "wght": control._size.fontWeight
                        }
                    }
                }
            }
        }

        IconButton {
            id: next
            x: control.leftPadding + control.contentItem.width
            iconGlyph: Fonts.FontInterface.icons.arrow_right_16
            sizeVariant: {
                switch (control.sizeVariant) {
                    case PaginationNumberStyle.SizeVariant.Small: return IconButtonStyle.SizeVariant.Small16
                    case PaginationNumberStyle.SizeVariant.Medium: return IconButtonStyle.SizeVariant.Medium16
                    case PaginationNumberStyle.SizeVariant.Large: return IconButtonStyle.SizeVariant.Large16

                    default: return IconButtonStyle.SizeVariant.Medium16
                }
            }
            appearanceVariant: control._outline ? IconButtonStyle.AppearanceVariant.Outline
                                                : IconButtonStyle.AppearanceVariant.Default

            enabled: control.currentIndex < control.count - 1

            onPressed: control.nextPressed()
        }
    }

    // THIS CODE IS AI GENERATED

    /**
     * Generates an array representing the pagination range to display
     * @param {number} count - Total number of pages
     * @param {number} currentPage - Current active page (0-indexed)
     * @param {number} siblingCount - Number of siblings to show on each side of current page
     * @param {number} boundaryCount - Number of pages to show at start and end
     * @returns {Array} Array of objects with page number and visibility metadata
     */
    function getPaginationRange(count, currentPage = 0, siblingCount = 1, boundaryCount = 1) {
        // Calculate target number of visible items (pages + ellipsis)
        // Formula: 2 boundaries + 1 current + 2*siblings + up to 2 ellipsis
        const targetVisibleCount = 2 * boundaryCount + 1 + 2 * siblingCount + 2;

        let actualSiblingCount = siblingCount;
        let bestVisiblePages = new Set();
        let bestTotalVisible = 0;

        // Expand sibling window if needed to reach target count, but don't exceed it
        while (actualSiblingCount < count) {
            const visiblePages = new Set();

            // Add boundary pages at the start
            for (let i = 0; i < Math.min(boundaryCount, count); i++)
                visiblePages.add(i);

            // Add boundary pages at the end
            for (let i = Math.max(0, count - boundaryCount); i < count; i++)
                visiblePages.add(i);

            // Add sibling pages around current page
            for (let i = Math.max(0, currentPage - actualSiblingCount); i <= Math.min(count - 1, currentPage + actualSiblingCount); i++)
                visiblePages.add(i);

            // Count gaps that will have ellipsis
            const sortedPages = Array.from(visiblePages).sort((a, b) => a - b);
            let ellipsisCount = 0;

            for (let i = 0; i < sortedPages.length - 1; i++) {
                const gap = sortedPages[i + 1] - sortedPages[i] - 1;
                if (gap > 1)
                    ellipsisCount++;
            }

            // Calculate total visible items (pages + ellipsis)
            const totalVisible = visiblePages.size + ellipsisCount;

            // Track the best option that doesn't exceed target
            if (totalVisible <= targetVisibleCount) {
                bestVisiblePages = visiblePages;
                bestTotalVisible = totalVisible;
            }

            // Stop if we've exceeded target or reached it
            if (totalVisible >= targetVisibleCount)
                break;

            actualSiblingCount++;
        }

        // Use the best visible pages we found
        const visiblePages = bestVisiblePages;

        // Build result array with only visible items
        const result = [];
        const sortedVisiblePages = Array.from(visiblePages).sort((a, b) => a - b);

        // Add visible pages and ellipsis between gaps
        for (let i = 0; i < sortedVisiblePages.length; i++) {
            const current = sortedVisiblePages[i];

            result.push({
                page: current,
                isEllipsis: false
            });

            // Check if there's a gap before the next visible page
            if (i < sortedVisiblePages.length - 1) {
                const next = sortedVisiblePages[i + 1];
                const gap = next - current - 1;

                if (gap === 1) {
                    // Single page gap: show the actual page number
                    result.push({
                        page: current + 1,
                        isEllipsis: false
                    });
                } else if (gap > 1) {
                    // Multiple pages gap: show ellipsis marker
                    result.push({
                        page: current + 1,
                        isEllipsis: true
                    });
                }
            }
        }

        return result;
    }
}
