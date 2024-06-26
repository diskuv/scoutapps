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

To customize the scouting software you will need a license to use the "DkSDK" software development kit. The license is free for First Robotics teams. **TBD: How?**

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
./dk src/SonicScout_Setup/Provision.ml --color=always --next
```

## Licenses

`Sonic Scout` is available under the [DkSDK SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT](./LICENSE-DKSDK).
The license is free to any First Robotics team who has an adult sponsor (ex. a mentor).
Contact jonah AT diskuv.com to get the license.

The copyright is owned jointly by:

- Archit Kumar
- Keyush Attarde
- Diskuv, Inc.

Do *not* submit a customized scouting application to an App Store (Apple, Google, Microsoft, Samsung, Huawei, Tencent, Oppo, etc.). You do not have a license to submit to those App Stores, and you don't own the copyright.

You *can* sideload your customized application on your team's tablets, phones and PCs. And you *can* (and *should*) submit a Pull Request for your changes so that next year's official scouting application includes your changes.
