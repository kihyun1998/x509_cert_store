---
status: accepted
---

# MSVC-compiled sources are ASCII-only

C++ and CMake files compiled by MSVC — since 3.0.0, only
`example/windows/runner/` — contain ASCII only, where peers use non-ASCII
freely. On a Korean Windows host (CP949) MSVC raises `C4819` for a character
the codepage cannot represent, and Flutter's default `/WX` escalates it to
`C2220`, failing the build. 2.0.1 fixed an instance of this that broke every
downstream app using the plugin.
