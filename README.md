# Sonic Scout Apps

Sonic Scout Apps is responsible for:

1. Being the place for official releases.
2. *For teams that want to [customize the scouting software](#customizing)*:
   - Checking out the Android frontend and Windows backend subprojects.
   - Generating source code that is shared by those subprojects.

Squirrel Scout is a First Robotics team from Glacier Peak High School, Washington State, USA. Two high school juniors (Archit Kumar and Keyush Attarde) wrote the initial versions of the Sonic Scout software with some help from Diskuv. Keeping with the First Robotics value system, the software has been released for use by other robotics teams.

- [Sonic Scout Apps](#sonic-scout-apps)
  - [Official Releases](#official-releases)
  - [Customizing](#customizing)
    - [Quick Start](#quick-start)
  - [Licenses](#licenses)

## Official Releases

Each year the First Robotics competitions change. The "official" release of the scouting software will always be one year prior. To be one step ahead of the other robotics teams, your team should [**modify** the scouting software](#customizing).

- TBD: Android App is in Play Store.
- TBD: Windows app should be in Releases.

## Customizing

The expectation is that any First Robotics team that uses and modifies the scouting software will continue to uphold First Robotics values by contributing their modifications back to these projects. Keep your modifications to yourself for the first year, and then submit a Pull Request with your changes the second year.

It is inevitable that one robotics team may submit modifications that are in conflict with modifications from another robotics team. Unfortunately there can only be one official release, and only one app submitted to the Google and Apple App Stores. To keep a healthy ["copyleft" open-source license](#licenses) for use by all robotics teams, Diskuv will moderate and decide which modification becomes part of the official release *and* your team will be asked to sign a [Contributor License Agreement](https://www.apache.org/licenses/contributor-agreements.html).

### Quick Start

> Prerequisite: A Windows 10 or Windows 11 PC with WSL installed. *Don't know if you have WSL? Follow <https://learn.microsoft.com/en-us/windows/wsl/install#install-wsl-command> which is safe even if WSL is already installed.*

If you haven't checked out this project onto your computer, you can do it now:

```sh
git clone https://gitlab.com/diskuv/sonicscout/scoutapps.git
cd scoutapps
```

Then in either **PowerShell on Windows** or a **macOS terminal** run:

```sh
./dk src/SonicScout_Setup/Develop.ml --color=always --next
```

After the end of the robotics season, you can save space by doing:

```sh
./dk src/SonicScout_Setup/Clean.ml --color=always --all
```

## Licenses

The source code of `Sonic Scout` is in the `src/` and `us/` folders are available
under the open source [OSL 3.0 license](./LICENSE-OSL3).

A guide to the Open Software License version 3.0 (OSL 3.0) is available at
<https://rosenlaw.com/OSL3.0-explained.htm>.

The `dk`, `dk.cmd` and `__dk.cmake` build tools are [OSL 3.0 licensed](./LICENSE-OSL3)
with prompts for additional licenses for the [LGPL 2.1 with an OCaml static linking exception](./LICENSE-LGPL21-ocaml) and the [DkSDK SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT](./LICENSE-DKSDK).

The backend app uses Qt5 which has a [LGPL 3.0 license](https://doc.qt.io/qt-5/licensing.html).

A DkSDK license token is necessary when you want to rebuild the applications with
customizations for your own robotics team. The token is free to any First Robotics team
who has an adult sponsor (ex. a mentor) who also agrees to submit their team's code changes at the end of each robotics season (a "pull request") using an open-source
[Contributor License Agreement](https://yahoo.github.io/oss-guide/docs/resources/what-is-cla.html).
Contact jonah AT diskuv.com to get a token.

You do *not* need a token to run the Android app from the Google Play Store, nor do you
need the license token to run the QR scanner backend app.

The copyright is owned jointly by:

- Archit Kumar
- Keyush Attarde
- Diskuv, Inc.

Do *not* submit a customized scouting application to an App Store (Apple, Google, Microsoft, Samsung, Huawei, Tencent, Oppo, etc.). You do not have a license to submit to those App Stores, and you don't own the copyright.

You *can* sideload your customized application on your team's tablets, phones and PCs.
