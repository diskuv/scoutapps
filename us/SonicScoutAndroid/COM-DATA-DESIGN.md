# Design

## D01: OCaml initialization and shutdown

Goal: Load and unload the OCaml runtime whenever the
application is visible (foreground) and invisible (background),
respectively. That reduces the amount of memory the
application uses, and makes it less likely that the
entire application is killed simply because of OCaml.

### D01-C01: Unload shared libraries not possible in Java

Constraint: Since Java has no mechanism for unloading a shared library
(no `dl_unload` equivalent for `System.loadLibrary()`),
we cannot do the clean method of shutting down the
OCaml runtime with `caml_shutdown`, then unloading
the shared library, and then re-loading the shared
library which would put all the static variables
back to a clean state.

### D01-C02: caml_shutdown can only be called once.

Constraint: Once `caml_shutdown` is called, we can no longer
do a subsequent `caml_startup`.

```c
int caml_startup_aux(int pooling)
{
  if (shutdown_happened == 1)
    caml_fatal_error("caml_startup was called after the runtime "
                     "was shut down with caml_shutdown");
  /* ... */
}                     
```

That means we have to find a different way
to load and unload the OCaml runtime repeatedly.

### D01-S01: caml_startup once while mimic caml_shutdown many times

Strategy: Our strategy is to do `caml_startup` once, and then do
similar but not equivalent steps as `caml_shutdown`.

Here is `caml_shutdown` in OCaml 4.14.0 and OCaml 5.1:

```c
CAMLexport void caml_shutdown(void)
{
  Caml_check_caml_state(); /* THIS LINE NOT IN OCAML 4.14.0 */
  if (startup_count <= 0)
    caml_fatal_error("a call to caml_shutdown has no "
                     "corresponding call to caml_startup");

  /* Do nothing unless it's the last call remaining */
  startup_count--;
  if (startup_count > 0)
    return;

  call_registered_value("Pervasives.do_at_exit"); /* DOES [Stdlib.flush_all ()] */
  call_registered_value("Thread.at_shutdown");
  caml_finalise_heap();
  caml_free_locale();
#ifndef NATIVE_CODE
  caml_free_shared_libs();
#endif
  caml_stat_destroy_pool();
  caml_terminate_signals(); /* THIS LINE NOT IN OCAML 4.14.0 */
#if defined(_WIN32) && defined(NATIVE_CODE)
  caml_win32_unregister_overflow_detection();
#endif

  shutdown_happened = 1;
}
```

#### D01-S01 - state transitions

```text
initialize -> start -> stop -> terminate
                ^        |
                |        |
                \--------/
```

#### D01-S01 - initialize

Do `caml_startup` once. But since part of `caml_startup` is registration of generational roots (allocations)
we need to do the `stop` logic so that the first `start` is in a good state.

Alternative: We could have skipped the first `start`, but it seems better to fail-fast if
there is a problem with `stop` -> `start` transition.

#### D01-S01 - start

Do the opposite of the following:

- `caml_terminate_signals()` - we want `caml_init_signals()` which was called in `caml_startup_common` and weirdly
  terminated in `caml_startup_common`. But the weirdness is only on Unix but not on Windows.
  https://github.com/ocaml/ocaml/issues/11486 has the bug. Because we do care about stack overflow detection,
  we _should_ enable the signals like the bug report says is preferable.

And do all the parts of `caml_startup` that use allocations (which are removed in `stop`).

#### D01-S01 - stop

And since we are not re-running `caml_startup`, we should not do
any of:

- `caml_free_locale()` - do not touch `caml_init_locale()` which was called in `caml_startup_common`
- `caml_free_shared_libs()` - keep any previously loaded shared libraries. Regardless, it is not for native code.
- `caml_stat_destroy_pool()` - keep the possible heap memory pool of `caml_stat_create_pool()` which was called in `caml_startup_aux`
- `caml_win32_unregister_overflow_detection()` - do not touch `caml_win32_overflow_detection()` which was called in `caml_startup_common`
- `shutdown_happened = 1` - that is a static variable so can't do anything anyway

And we also get rid of all the roots (the global/generational roots and the local stack).

Also, there is a warning on `caml_finalise_heap`:

```c
/* Forces finalisation of all heap-allocated values,
   disregarding both local and global roots.

   Warning: finalisation is performed by means of forced sweeping, which may
   result in pointers referencing nonexistent values; therefore the function
   should only be used on runtime shutdown.
*/
```

To get rid of those nonexistent values, we need to reset the
major heap. That is, we need to do a `caml_compact_heap`.

#### D01-S01 - terminate

Finally, when we do shutdown the JVM, we should do the bits of `caml_shutdown`
that have not already been done. We can do all of the remainder except:

- `call_registered_value("Thread.at_shutdown")` - since there are no OCaml values in memory no callback could have been registered
- `caml_free_shared_libs()` - since it is not for native code (and won't have an export symbol in the library)

**That means threads are not supported (or more accurately there will be a leak) in this reloadable OCaml runtime.** And that is okay and somewhat makes sense.
