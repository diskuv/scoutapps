#ifndef SQUIRREL_SCOUT_MANAGER_H
#define SQUIRREL_SCOUT_MANAGER_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Initialize the the OCaml portion of the Squirrel Scout manager.
 * 
 * Any options on the command line after a <code>--</code>, if any,
 * will be sent to OCaml as command line options.
 * 
 * Any non-OCaml options will be sent back to you (the C caller)
 * in the last two output arguments.
 * 
 * @param argc0 - [in] The original command line argument count
 * @param argv0 - [in] The original command line argument array
 * @param argc - [out] The address of the command line argument count
 * to be modified
 * @param argv - [out] The address of the command line argument array
 * to be modified
 */
extern void squirrel_scout_manager_init(
    int argc0, char* argv0[],
    int *argc, char** argv[]
);

/**
 * Attempt to close and release any Squirrel Scout resources gracefully.
 */
extern void squirrel_scout_manager_destroy();

/**
 * Send the QR code to the OCaml portion of the Squirrel Scout manager.
 * 
 * @param format - [in] The [BarcodeFormatName](@ref BarcodeFormatName)
 * @param bytesBuf - [in] The starting address of the QR code bytes.
 * @param bytesLen - [in] The length of the QR code buffer.
 */
extern void squirrel_scout_manager_consume_qr(
    const char* barcodeFormatName,
    const char* bytesBuf,
    size_t bytesLen
);

#ifdef __cplusplus
}
#endif

#endif /*SQUIRREL_SCOUT_MANAGER_H*/