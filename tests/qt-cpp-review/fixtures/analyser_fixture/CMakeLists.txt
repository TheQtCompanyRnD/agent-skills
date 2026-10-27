# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
#
# Smallest compilable Qt project for the clang-tidy/clazy smoke test in
# ../../run_tests.py. Never built, only configured for compile_commands.json.
cmake_minimum_required(VERSION 3.16)
project(analyser_fixture LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core)

add_library(analyser_fixture STATIC smoke.cpp)
target_link_libraries(analyser_fixture PRIVATE Qt6::Core)
