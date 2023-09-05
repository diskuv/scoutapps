include(FetchContent)

FetchContent_Declare(zxing-cpp
    GIT_REPOSITORY https://github.com/zxing-cpp/zxing-cpp.git
    GIT_TAG 1bb03a85ef9846076fc5068b05646454f7fe6f6f # v2.1.0
)

set(BUILD_BLACKBOX_TESTS OFF)
set(BUILD_EXAMPLES OFF)
set(BUILD_SHARED_LIBS OFF) # Easiest to deploy is static library

message(CHECK_START "Fetching zxing")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

FetchContent_MakeAvailable(zxing-cpp)

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")
