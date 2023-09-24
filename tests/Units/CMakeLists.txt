DkSDKProject_AddPackage(AUTO_OPAM_PACKAGE TESTS)

include(DkSDKTest)

# Test Std
DkSDKTest_AddUnitTest(NAME Std
  STANDARD_MAIN

  ML_RUNTIME SquirrelScout::Std
  
  )

# Create an executable so that we know that
# the Objs library can be linked with all of its
# necessary libraries.
add_executable(test-Objs ${DKSDK_TESTING_MAIN_C})
target_link_libraries(test-Objs PRIVATE
        SquirrelScout::Objs DkSDK::OCamlCompile DkSDK::OCamlDependencies)
add_test(NAME test-Objs COMMAND test-Objs)

# Arithmetic is a standalone unit test. It is here simply to
# show you how to include C code in a unit test.
# DkSDKTest_AddUnitTest(NAME arithmetic
#   STANDARD_MAIN)

add_subdirectory(ManagerApp)
