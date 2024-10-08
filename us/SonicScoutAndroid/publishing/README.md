# Publishing

## Android Play Store Listing

### Screenshots

> All the following emulators used Android 12.0 on x86_64 ("S"; API 31).

`PhoneScreenshotPixelXL31` is a Google Play Store phone screenshots emulator:
- `Pixel XL` is 1440x2560 560dpi which is high-res 9:16 ratio needed for screenshots

`TabletScreenshot7WSVGA` is a Google Play Store tablet screenshots emulator:
- `7" WSVGA (Tablet)` is 600x1024 mdpi which is 7" 16:9 (almost) ratio needed for 7" tablet screenshots.

`TabletScreenshotNexus10` is a Google Play Store tablet screenshots emulator:
- `Nexus 10` is 600x1024 mdpi which is 10.05" 16:9 (almost) ratio needed for 10" tablet screenshots.

To run the emulators the following in the `app/build.gradle` and `data/build.gradle` need to be changed from

```
abiFilters 'arm64-v8a'
```

to

```
abiFilters 'x86_64'
```

**DO NOT PUSH THAT CHANGE**.

## Keys

Signing keys are the master key for the Google Play Store.
You can generate [upload keys](#upload-keys) whenever an upload key is compromised.

You register both the signing key and the current upload key when you publish an app.

- The signing key must be protected and never revealed for ~27 years.
- The upload keys should also be protected.

Full details are at https://developer.android.com/studio/publish/app-signing

In the steps in this section we:

- give Google a copy of the master signing key (the key is encrypted before being sent)
- give Google a copy of the current upload key (the key is encrypted before being sent)

Anybody who has the current upload key can upload a new app to Google Play Store.
However, once a new upload key is generated the old upload keys become invalid.

It is best to think of the upload key as a username/password which can be changed.
The upload key is only used to tell Google you are a valid uploader for the app.

The signing key (the public side of it) is what gives a secure stamp to the Android app itself.
Google does the signing (secure stamping) of the Android app itself, once Google knows you are who you say you are (through the upload key).

Never ever use the signing key to upload the Android app.
In fact, you should never have to use the signing key.
It is kept only so that you can register Android apps on a different App Store (ex. Amazon App Store).

### Signing Keys

#### Generating a new signing key

You **do not** want to regenerate the signing keys. This section is only here for educational purposes.

On Windows, after you have installed Java, run the following in Windows:

```powershell
keytool -genkeypair -v -storetype PKCS12 -keystore sonic-scout-signing-key.keystore -alias sonic-scout-signing-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

```text
Enter keystore password:  ... create a new password at least 14 characters long ...
Re-enter new password: ...
What is your first and last name?
  [Unknown]:  Archit Kumar, Keyush Attarde, and Diskuv, Inc.
What is the name of your organizational unit?
  [Unknown]:  Robotics
What is the name of your organization?
  [Unknown]:  Diskuv
What is the name of your City or Locality?
  [Unknown]:  Snohomish County
What is the name of your State or Province?
  [Unknown]:  Washington
What is the two-letter country code for this unit?
  [Unknown]:  US
Is CN="Archit Kumar, Keyush Attarde, and Diskuv, Inc.", OU=Robotics, O=Diskuv, L=Snohomish County, ST=Washington, C=US correct?
  [no]:  yes

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
        for: CN="Archit Kumar, Keyush Attarde, and Diskuv, Inc.", OU=Robotics, O=Diskuv, L=Snohomish County, ST=Washington, C=US
[Storing sonic-scout-signing-key.keystore]
```

> Please use a hardware device! The recommendation is to make a Secure Document entry
> (ex. `Sonic Scout Android Signing Key`) and place `sonic-scout-signing-key.keystore` inside
> the entry. Then add a password field to the entry (label it the `keystore password`) which will
> have the keystore password you entered earlier.

### Upload Keys

#### Generating a new upload key

The only reason to generate a new upload key is if you suspect or know someone compromised the old upload key, or if the old upload key expired after 10 years.

The instructions are very similar to [Generating a new signing key](#generating-a-new-signing-key), so make sure to copy and paste exactly.

Run the following on Windows in PowerShell ... use a _different_ password than the signing key password:

```powershell
keytool -genkeypair -v -storetype PKCS12 -keystore sonic-scout-upload-key.keystore -alias sonic-scout-upload-key-alias -keyalg RSA -keysize 2048 -validity 3650
```

```text
Enter keystore password:  ... create a new password at least 14 characters long ...
Re-enter new password: ...
What is your first and last name?
  [Unknown]:  Archit Kumar, Keyush Attarde, and Diskuv, Inc.
What is the name of your organizational unit?
  [Unknown]:  Robotics
What is the name of your organization?
  [Unknown]:  Diskuv
What is the name of your City or Locality?
  [Unknown]:  Snohomish County
What is the name of your State or Province?
  [Unknown]:  Washington
What is the two-letter country code for this unit?
  [Unknown]:  US
Is CN="Archit Kumar, Keyush Attarde, and Diskuv, Inc.", OU=Robotics, O=Diskuv, L=Snohomish County, ST=Washington, C=US correct?
  [no]:  yes

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
        for: CN="Archit Kumar, Keyush Attarde, and Diskuv, Inc.", OU=Robotics, O=Diskuv, L=Snohomish County, ST=Washington, C=US
[Storing sonic-scout-upload-key.keystore]
```

> Please use a secure password manager or a hardware key! The recommendation is to make a Secure Document entry
> (ex. `Sonic Scout Android Current Upload Key`) and place `sonic-scout-upload-key.keystore` inside
> the entry. Then add a password field to the entry (label it the `keystore password`) which will
> have the keystore password you entered earlier.

### Registering with Google Play Store

#### Registering the signing key the first time

> Once you are registered, you will never need to redo this section

When you are in the Google Play Console (https://play.google.com/console) you can do an "internal testing release".
That will allow you to register your signing key and your first upload key.
Google will:
1. Give you an "encryption public key".
2. Give you a "PEPK tool".

Let's say you downloaded those to your Downloads folder. In PowerShell:

```powershell
java -jar "$env:USERPROFILE\Downloads\pepk.jar" --keystore=sonic-scout-signing-key.keystore --alias=sonic-scout-signing-key-alias --output=encrypted-signing-key.zip --include-cert --rsa-aes-encryption --encryption-key-path="$env:USERPROFILE\Downloads\encryption_public_key.pem"
```

The "password for store" and the "password for key" are the same as what you entered on [Generating a new signing key](#generating-a-new-signing-key)

Now in the Google Play Console it will have a button to **Upload generated ZIP**.
The `encrypted-signing-key.zip` is what you upload.

Continue on to the [Registering the current upload key](#registering-the-current-upload-key)

#### Registering the current upload key

Make sure you have available the current upload key.
It should be called `sonic-scout-upload-key.keystore`.
If you need a new one follow [Generating a new upload key](#generating-a-new-upload-key).

In PowerShell:

```powershell
keytool -export -rfc -keystore sonic-scout-upload-key.keystore -alias sonic-scout-upload-key-alias -file sonic-scout-upload-certificate.pem
```

The "keystore password" is the same as what you entered on [Generating a new upload key](#generating-a-new-upload-key)

Now in the Google Play Console it will have a button to **Upload your upload key certificate**.
The `sonic-scout-upload-certificate.pem` is what you upload.

### Creating a Signed Bundle

Theoretically the `Build > Generate Signed Bundle` menu, and selecting the **release** variant should work.
But Google Play Console sometimes complains that the bundle is not signed!

**If that happens**, take that supposedly signed bundle (default location is `app/release/app-release.aab`) and sign it manually with:

```powershell
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore sonic-scout-upload-key.keystore -signedjar sonic-scout.aab app/release/app-release.aab sonic-scout-upload-key-alias
```
