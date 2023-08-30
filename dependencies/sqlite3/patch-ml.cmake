##########################################################################
# File: dksdk-cmake/patch-ml.cmake                                       #
#                                                                        #
# Copyright 2023 Diskuv, Inc.                                            #
#                                                                        #
# Licensed under the DkSDK SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT    #
# (the "License"); you may not use this file except in compliance        #
# with the License. You may obtain a copy of the License at              #
#                                                                        #
#     https://diskuv.com/legal/                                          #
#                                                                        #
##########################################################################

if (NOT DESTDIR)
    message(FATAL_ERROR "The -D DESTDIR=... must be set")
endif()
if (NOT PATCHDIR)
    message(FATAL_ERROR "The -D PATCHDIR=... must be set")
endif()

configure_file("${PATCHDIR}/discover.ml" "${DESTDIR}/src/config/discover.ml" COPYONLY)
configure_file("${PATCHDIR}/src.dune" "${DESTDIR}/src/dune" COPYONLY)
