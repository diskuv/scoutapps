DkSDKProject_AddPackage(AUTO_OPAM_PACKAGE TESTS)

include(DkSDKTest)

# Test Std
DkSDKTest_AddUnitTest(NAME Std
  STANDARD_MAIN

  ML_RUNTIME SquirrelScout::Std)

# Test Objs
DkSDKTest_AddUnitTest(NAME Objs
  MAIN generic-ffi-main.c

  # dksdk_ffi_c_logger_initConsoleLogger() is in generic-ffi-main.c
  C_RUNTIME DkSDK::FFI::C-Static

  ML_RUNTIME SquirrelScout::Objs)

add_subdirectory(ManagerApp)
