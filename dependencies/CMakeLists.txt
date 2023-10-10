include(DkSDKFetchContent)
include(DkSDKProject)
DkSDKProject_AddDependencies()

# --- Set dksdk-BASE_REPOSITORY_URL
get_property(dksdk-BASE_REPOSITORY_URL GLOBAL PROPERTY DKSDK_BASE_REPOSITORY_URL)

# --- Set dksdk-ffi-java_REPOSITORY
if(DEFINED ENV{DKSDK_FFI_JAVA_REPO_${REQUEST_DKSDK_VERSION_underscore}}) # override repository with environment variable
    # potential sensitive user data
    set(dksdk-ffi-java_REPOSITORY "$ENV{DKSDK_FFI_JAVA_REPO_${REQUEST_DKSDK_VERSION_underscore}}")
    message(STATUS "Using DkSDK FFI Java repository from the DKSDK_FFI_JAVA_REPO_${REQUEST_DKSDK_VERSION_underscore} environment variable")
elseif(NOT dksdk-ffi-java_REPOSITORY)
    set(dksdk-ffi-java_REPOSITORY "${dksdk-BASE_REPOSITORY_URL}/dksdk-ffi-java.git")
endif()

if(DEFINED ENV{DKSDK_TOKEN_${REQUEST_DKSDK_VERSION_underscore}}) # ie. authentication for properly configured CI
    # potential sensitive user data
    string(REGEX REPLACE "^https://" "https://oauth2:$ENV{DKSDK_TOKEN_${REQUEST_DKSDK_VERSION_underscore}}@"
        dksdk-ffi-java_REPOSITORY "${dksdk-ffi-java_REPOSITORY}")
    message(STATUS "Adding token from DKSDK_TOKEN_${REQUEST_DKSDK_VERSION_underscore} environment variable to the DkSDK FFI Java repository")
endif()

# --- Fetch dksdk-ffi-java

FetchContent_Declare(dksdk-ffi-java # override with cmake -D FETCHCONTENT_SOURCE_DIR_DKSDK-FFI-JAVA=...
    GIT_REPOSITORY "${dksdk-ffi-java_REPOSITORY}"
    GIT_TAG main)
DkSDKFetchContent_MakeAvailableNoInstall(dksdk-ffi-java)
