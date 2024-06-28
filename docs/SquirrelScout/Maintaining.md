# Maintaining

## Packaging for release

Do the following on macOS:

```sh
./dk src/SonicScout_Setup/Package.ml --color=always --notarize

open us/SonicScoutBackend/build_dev/_CPack_Packages/Darwin/TGZ/SonicScoutBackend-1.0.0-Darwin/SonicScoutQRScanner.dmg
```

## Incorporating other people's contributions

Important: Make sure the contributors have agreed to a CLA.

The source code should be updated yearly for the First Robotics community.

We use a technique called "git subtree" to manage the source code in the `us/` folder.
That technique is explained at <https://www.atlassian.com/git/tutorials/git-subtree>.

In particular, the source for the 2023-2024 season came from:

```sh
git subtree add --prefix us/SonicScoutBackend https://github.com/SquirrelScout/ocaml-backend.git main
git subtree add --prefix us/SonicScoutAndroid https://github.com/SquirrelScout/SquirrelScout_Scouter.git main
```

Then when any updates are needed inside this Scout Apps project:

```sh
git subtree pull --prefix us/SonicScoutBackend https://github.com/SquirrelScout/ocaml-backend.git main
git subtree pull --prefix us/SonicScoutAndroid https://github.com/SquirrelScout/SquirrelScout_Scouter.git main
```

And when moving changes from the `us/` directories back to their authoritative projects, do:

```sh
git subtree push --prefix us/SonicScoutBackend https://github.com/SquirrelScout/ocaml-backend.git main
git subtree push --prefix us/SonicScoutAndroid https://github.com/SquirrelScout/SquirrelScout_Scouter.git main
```
