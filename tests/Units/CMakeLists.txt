DkSDKProject_AddPackage(AUTO_OPAM_PACKAGE TESTS)

include(DkSDKTest)

# Test Std
DkSDKTest_AddUnitTest(NAME Std
  STANDARD_MAIN

  ML_RUNTIME SquirrelScout::Std)

# Test Objs
DkSDKTest_AddUnitTest(NAME Objs
  STANDARD_MAIN
  ML_RUNTIME SquirrelScout::Objs)

add_subdirectory(ManagerApp)
