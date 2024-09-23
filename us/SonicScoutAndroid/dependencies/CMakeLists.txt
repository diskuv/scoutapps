include(DkSDKFetchContent)
include(DkSDKProject)
DkSDKProject_AddDependencies()

# --- Set dksdk-BASE_REPOSITORY_URL
get_property(dksdk-BASE_REPOSITORY_URL GLOBAL PROPERTY DKSDK_BASE_REPOSITORY_URL)

## START DKSDK ~~~~~~~~~~~~~~~~~

# TODO: This belongs in DkSDKAccess or something similar
macro(use_dksdk_ffi_repository UPPER_NAME LOWER_NAME)
    if(DEFINED ENV{DKSDK_FFI_${UPPER_NAME}_REPO_${REQUEST_DKSDK_VERSION_underscore}}) # override repository with environment variable
        # potential sensitive user data
        set(dksdk-ffi-${LOWER_NAME}_REPOSITORY "$ENV{DKSDK_FFI_${UPPER_NAME}_REPO_${REQUEST_DKSDK_VERSION_underscore}}")
        message(STATUS "Using DkSDK FFI ${LOWER_NAME} repository from the DKSDK_FFI_${UPPER_NAME}_REPO_${REQUEST_DKSDK_VERSION_underscore} environment variable")
    elseif(NOT dksdk-ffi-${LOWER_NAME}_REPOSITORY)
        set(dksdk-ffi-${LOWER_NAME}_REPOSITORY "${dksdk-BASE_REPOSITORY_URL}/dksdk-ffi-${LOWER_NAME}.git")
    endif()

    if(DEFINED ENV{DKSDK_TOKEN_${REQUEST_DKSDK_VERSION_underscore}}) # ie. authentication for properly configured CI
        # potential sensitive user data
        string(REGEX REPLACE "^https://" "https://oauth2:$ENV{DKSDK_TOKEN_${REQUEST_DKSDK_VERSION_underscore}}@"
                dksdk-ffi-${LOWER_NAME}_REPOSITORY "${dksdk-ffi-${LOWER_NAME}_REPOSITORY}")
        message(STATUS "Adding token from DKSDK_TOKEN_${REQUEST_DKSDK_VERSION_underscore} environment variable to the DkSDK FFI ${UPPER_NAME} repository")
    endif()
endmacro()
use_dksdk_ffi_repository(JAVA java)
use_dksdk_ffi_repository(OCAML ocaml)

# --- Fetch dksdk-ffi-java

set(DKSDK_FFI_JAVA_EMBEDDER_LIBRARY data_foreground)
DkSDKFetchContent_DeclareSecondParty(NAME dksdk-ffi-java
    GIT_REPOSITORY "${dksdk-ffi-java_REPOSITORY}"
    GIT_TAG next)
if(NOT GENERATE_CAPNP_ONLY)
    DkSDKFetchContent_MakeAvailableNoInstall(dksdk-ffi-java)
endif()

## END DKSDK ~~~~~~~~~~~~~~~~~

## START USER ~~~~~~~~~~~~~~~~~

# This section is for dependencies that the DkSDK user brings.

# --- Local override

set(SONIC_SCOUT_BACKEND_FEATURES Objs)
DkSDKFetchContent_DeclareSecondParty(
        NAME ocaml-backend
        GIT_REPOSITORY "https://github.com/SquirrelScout/ocaml-backend.git"
        GIT_TAG teamNamesTable)
if(NOT GENERATE_CAPNP_ONLY)
    DkSDKFetchContent_MakeAvailableToDune(ocaml-backend)
endif()

## END USER ~~~~~~~~~~~~~~~~~
