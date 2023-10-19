include(DkSDKFetchContent)
include(DkSDKProject)
DkSDKProject_AddDependencies()

# --- Set dksdk-BASE_REPOSITORY_URL
get_property(dksdk-BASE_REPOSITORY_URL GLOBAL PROPERTY DKSDK_BASE_REPOSITORY_URL)

## START DKSDK ~~~~~~~~~~~~~~~~~

# This section of dependencies is supplied by the DkSDK "com.diskuv.dksdk.core.gradle"
# Java plugin's CMakeConfigureTask which adds properties like
# -DFETCHCONTENT_SOURCE_DIR_DKSDK-FFI-C=xxx with default values from
# ffi-java-android-standalone CMakeConfigureTask arguments like
# [defaultFetchContentDksdkFfiOCaml = rootProject.file("fetch/dksdk-ffi-ocaml")].

# TODO: This belongs in DkSDKAccess or something similar
macro(use_dksdk_ffi_repository UPPER_NAME LOWER_NAME)
    if(DEFINED ENV{DKSDK_FFI_${UPPER_NAME}_REPO_${REQUEST_DKSDK_VERSION_underscore}}) # override repository with environment variable
        # potential sensitive user data
        set(dksdk-ffi-${LOWER_NAME}_REPOSITORY "$ENV{DKSDK_FFI_${UPPER_NAME}_REPO_${REQUEST_DKSDK_VERSION_underscore}}")
        message(STATUS "Using DkSDK FFI Java repository from the DKSDK_FFI_${UPPER_NAME}_REPO_${REQUEST_DKSDK_VERSION_underscore} environment variable")
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

set(DKSDK_FFI_JAVA_EMBEDDER_LIBRARY datalib)
FetchContent_Declare(dksdk-ffi-java # override with cmake -D FETCHCONTENT_SOURCE_DIR_DKSDK-FFI-JAVA=...
    GIT_REPOSITORY "${dksdk-ffi-java_REPOSITORY}"
    GIT_TAG next)
DkSDKFetchContent_MakeAvailableNoInstall(dksdk-ffi-java)

# --- Declare dksdk-ffi-ocaml but MakeAvailable will happen in START USER (ocaml-backend)

FetchContent_Declare(dksdk-ffi-ocaml # override with cmake -D FETCHCONTENT_SOURCE_DIR_DKSDK-FFI-OCAML=...
        GIT_REPOSITORY "${dksdk-ffi-ocaml_REPOSITORY}"
        GIT_TAG next)

## END DKSDK ~~~~~~~~~~~~~~~~~

## START USER ~~~~~~~~~~~~~~~~~

# This section is for dependencies that the DkSDK user brings.

# --- Local override

# Normally we ask for CMakeUserPresets.json to define FETCHCONTENT_SOURCE_DIR_OCAML-BACKEND
# (etc). But we don't use presets with the Android Gradle Plugin (that would stomp out AGP's
# ABI-specific binary directory). So we do local overrides manually!
# But just for convenience, let's do it if it hasn't been set.
function(DeclareButAllowLocalOverride)
    set(noValues)
    set(singleValues NAME GIT_REPOSITORY GIT_TAG)
    set(multiValues)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "${noValues}" "${singleValues}" "${multiValues}")

    # ex. ocaml-backend -> FETCHCONTENT_SOURCE_DIR_OCAML-BACKEND
    string(TOUPPER "FETCHCONTENT_SOURCE_DIR_${ARG_NAME}" fetchcontent_VARNAME)

    # if there is a directory for overriding, use it
    if(NOT ${fetchcontent_VARNAME})
        set(pdir "${PROJECT_SOURCE_DIR}/../${ARG_NAME}")
        cmake_path(GET pdir PARENT_PATH pdir)
        if(IS_DIRECTORY "${pdir}/${ARG_NAME}")
            set(${fetchcontent_VARNAME} "${pdir}/${ARG_NAME}")
        elseif(IS_DIRECTORY "${PROJECT_SOURCE_DIR}/fetch/${ARG_NAME}")
            set(${fetchcontent_VARNAME} "${PROJECT_SOURCE_DIR}/fetch/${ARG_NAME}")
        endif()
    endif()

    FetchContent_Declare(${ARG_NAME}
            GIT_REPOSITORY "${ARG_GIT_REPOSITORY}"
            GIT_TAG ${ARG_GIT_TAG})
    DkSDKFetchContent_MakeAvailableNoInstall(${ARG_NAME})
endfunction()

DeclareButAllowLocalOverride(
        NAME ocaml-backend
        GIT_REPOSITORY "https://github.com/SquirrelScout/ocaml-backend.git"
        GIT_TAG teamNamesTable)

## END USER ~~~~~~~~~~~~~~~~~
