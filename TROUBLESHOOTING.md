# Troubleshooting

## Using Ninja to rerun CMake configuration

Change `4q2j6g5i` and `arm64-v8a` appropriately.

```sh
ninja -C data/.cxx/Debug/4q2j6g5i/arm64-v8a rebuild_cache
```

## Using Ninja to run CMake build

Change `4q2j6g5i` and `arm64-v8a` appropriately.

```sh
ninja -C data/.cxx/Debug/4q2j6g5i/arm64-v8a data_foreground
```