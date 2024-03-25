cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "x509_cert_store")
project(${PROJECT_NAME} LANGUAGES CXX)
cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "x509_cert_store_plugin")
list(APPEND PLUGIN_SOURCES
  "x509_cert_store_plugin.cpp"
  "x509_cert_store_plugin.h"
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

# # === Tests ===
# # These unit tests can be run from a terminal after building the example, or
# # from Visual Studio after opening the generated solution file.

# # Only enable test builds when building the example (which sets this variable)
# # so that plugin clients aren't building the tests.
# if (${include_${PROJECT_NAME}_tests})
# set(TEST_RUNNER "${PROJECT_NAME}_test")
# enable_testing()

# # Add the Google Test dependency.
# include(FetchContent)
# FetchContent_Declare(
#   googletest
#   URL https://github.com/google/googletest/archive/release-1.11.0.zip
# )
# # Prevent overriding the parent project's compiler/linker settings
# set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# # Disable install commands for gtest so it doesn't end up in the bundle.
# set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
# FetchContent_MakeAvailable(googletest)

# # The plugin's C API is not very useful for unit testing, so build the sources
# # directly into the test binary rather than using the DLL.
# add_executable(${TEST_RUNNER}
#   test/x509_cert_store_plugin_test.cpp
#   ${PLUGIN_SOURCES}
# )
# apply_standard_settings(${TEST_RUNNER})
# target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
# target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
# target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)
# # flutter_wrapper_plugin has link dependencies on the Flutter DLL.
# add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
#   COMMAND ${CMAKE_COMMAND} -E copy_if_different
#   "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
# )

# # Enable automatic test discovery.
# include(GoogleTest)
# gtest_discover_tests(${TEST_RUNNER})
# endif()
