# Maintaining

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
