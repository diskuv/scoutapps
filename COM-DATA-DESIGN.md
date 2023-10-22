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

Since the following have OCaml top-level initializers which can't
be re-run, we should not do any of:

- `call_registered_value("Thread.at_shutdown")` - do not touch `caml_thread_initialize(value)` and do not reset `preempt_signal`, both from `[ocaml]/otherlibs/systhreads/thread.ml`

And since we are not re-running `caml_startup`, we should not do
any of:

- `caml_free_locale()` - do not touch `caml_init_locale()` which was called in `caml_startup_common`
- `caml_free_shared_libs()` - keep any previously loaded shared libraries
- `caml_stat_destroy_pool()` - keep the possible heap memory pool of `caml_stat_create_pool()` which was called in `caml_startup_aux`
- `caml_terminate_signals()` - do not touch `caml_init_signals()` which was called in `caml_startup_common`
- `caml_win32_unregister_overflow_detection()` - do not touch `caml_win32_overflow_detection()` which was called in `caml_startup_common`
- `shutdown_happened = 1` - that is a static variable so can't do anything anyway

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
