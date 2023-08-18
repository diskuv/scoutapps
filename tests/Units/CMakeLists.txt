DkSDKProject_AddPackage(AUTO_OPAM_PACKAGE TESTS)

include(DkSDKTest)

# Test HelloLib
DkSDKTest_AddUnitTest(NAME HelloLib
  STANDARD_MAIN

  ML_RUNTIME SquirrelScout::HelloLib)

# Arithmetic is a standalone unit test. It is here simply to
# show you how to include C code in a unit test.
DkSDKTest_AddUnitTest(NAME arithmetic
  STANDARD_MAIN)
