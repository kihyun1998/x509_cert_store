cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "x509_cert_store")
project(${PROJECT_NAME} LANGUAGES CXX)
cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "x509_cert_store_plugin")
list(APPEND PLUGIN_SOURCES
  "x509_cert_store_plugin.cpp"
  "x509_cert_store_plugin.h"
  "x509_cert_store_categories.h"
)
add_library(${PLUGIN_NAME} SHARED
  "include/x509_cert_store/x509_cert_store_plugin_c_api.h"
  "x509_cert_store_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin Crypt32.lib)
set(x509_cert_store_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===
# The test target is compiled when include_${PROJECT_NAME}_tests is set. The
# example app's own CMakeLists sets it TRUE by convention, so these tests build
# as part of `flutter build windows`. Test discovery is deferred to ctest time
# (DISCOVERY_MODE PRE_TEST below) so the app build itself never runs the test
# binary, which needs flutter_windows.dll on PATH.
if (${include_${PROJECT_NAME}_tests})
set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()

# Load GoogleTest using FetchContent.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip
)
# Prevent overriding the parent project's compiler/linker settings.
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Do not let GoogleTest add install() rules. Otherwise `flutter build`'s INSTALL
# step tries to install GoogleTest into the system prefix and fails with
# "file INSTALL cannot make directory".
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# The plugin's exported API is not useful for unit testing, so build the plugin
# sources directly into the test binary rather than linking the shared library.
add_executable(${TEST_RUNNER}
  "test/x509_cert_store_plugin_test.cpp"
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
target_link_libraries(${TEST_RUNNER} PRIVATE Crypt32.lib)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)
target_compile_definitions(${TEST_RUNNER} PRIVATE FLUTTER_PLUGIN_IMPL)

# Enable automatic test discovery. PRE_TEST discovers tests when ctest runs
# rather than at build time: the test binary links the Flutter C++ wrapper and
# needs flutter_windows.dll at runtime, which is not beside the binary during
# `flutter build`, so build-time (POST_BUILD) discovery would fail the build.
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER} DISCOVERY_MODE PRE_TEST)
endif()