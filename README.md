# Persona Generator

Persona Generator is an iOS app written in SwiftUI. It lets you create fictional personas and store them as CloudKit records in the private database of the signed-in iCloud account.

Each persona stores a title, profile image, name, headline, bio, birthdate, email, phone, website, a favorite flag, and extra images. A profile image can come from the photo library, the device camera, or a download of `https://thispersondoesnotexist.com/image`.

## Prerequisites

- A Mac with Xcode. `PersonaGenerator/PersonaGenerator.xcodeproj/project.pbxproj` records `CreatedOnToolsVersion` 14.1 and `LastUpgradeCheck` 1410.
- iOS 16.1 or later. `IPHONEOS_DEPLOYMENT_TARGET` is `16.1`. The target supports iPhone and iPad (`TARGETED_DEVICE_FAMILY` is `1,2`).
- Swift 5. `SWIFT_VERSION` is `5.0`.
- An Apple ID in Xcode with iCloud. The PersonaGenerator target uses automatic signing. The development team and bundle identifier are set in `project.pbxproj`. Select your own team in Xcode when that signing identity is not yours.
- CloudKit, declared in `PersonaGenerator/PersonaGenerator/PersonaGenerator.entitlements`. The file enables the CloudKit service and an iCloud container identifier. The same file sets `aps-environment` to `development`. The Swift sources do not register for remote notifications.
- Network access for the downloaded profile image.

There is no package manager manifest. The app links only system frameworks: SwiftUI, CloudKit, UIKit, and PhotosUI.

The generated Info.plist settings in the project do not include camera or photo library usage description keys.

## Install, build, run, and test

There is no separate install step.

Open the project:

```bash
open PersonaGenerator/PersonaGenerator.xcodeproj
```

The repo does not contain a shared `.xcscheme` file. Xcode creates a scheme for the PersonaGenerator application target when the project opens. Select that scheme, choose an iOS Simulator or a device, and run the target.

Command-line Debug build for the iOS Simulator. `CODE_SIGNING_ALLOWED=NO` skips the development team:

```bash
xcodebuild \
  -project PersonaGenerator/PersonaGenerator.xcodeproj \
  -target PersonaGenerator \
  -sdk iphonesimulator \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Release configuration:

```bash
xcodebuild \
  -project PersonaGenerator/PersonaGenerator.xcodeproj \
  -target PersonaGenerator \
  -sdk iphonesimulator \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  build
```

A signed device build is done from Xcode after you select a development team for the bundle identifier in the project.

The Xcode project has one application target, PersonaGenerator, and no test target. There is no test command in this repo.

## Usage

The app starts on a screen titled Manage Personas. On first appear it loads every record of type `Persona` from `CKContainer.default().privateCloudDatabase`.

- Search keeps rows whose title contains the query, ignoring case.
- All shows every loaded persona. Favorites shows rows whose `isFavorite` flag is true.
- Pull to refresh fetches the records again.
- Swipe a row, or use Edit, to delete that record from CloudKit.
- The star on a row toggles `isFavorite` and saves the record.
- Add Persona opens a sheet for a new record.
- A long press on a row, and Edit on the detail screen, open the same sheet for an existing record.

The detail screen shows the profile image, name, headline, bio, email, website, phone, and extra images. Birthdate is stored on the record and edited in the sheet.

The sheet fields are title, name, headline, bio, birthday, email, website, and phone. Save creates a private-database record or updates the existing one.

The profile image control has three actions:

- Choose Photo from Gallery selects one photo with `PhotosPicker`.
- Camera presents `UIImagePickerController` when a camera is available. Otherwise the button is disabled and the error text is "Camera not available".
- AI Generated Random calls `ViewModel.fetchImage`, which requests `https://thispersondoesnotexist.com/image` and uses the image data as the profile image.

Choose Photos from Gallery, under the extra images, adds up to five photos with `PhotosPicker`. Long press an extra image and choose Delete to remove it before saving.

CloudKit and image errors are shown in an alert.

## Layout

```
PersonaGenerator/
  PersonaGenerator.xcodeproj/          Xcode project, one app target
  PersonaGenerator/
    PersonaGeneratorApp.swift          App entry
    ContentView.swift                  Shows the persona list
    PersonaGenerator.entitlements      CloudKit, iCloud container, aps-environment
    Assets.xcassets/                   App icon and accent color
    Preview Content/                   SwiftUI preview assets
  PersonaModel.swift                   Persona fields and CloudKit record mapping
  ViewModel.swift                      Fetch, create, update, delete, image download
  ManagePersonasListView.swift         List, search, filter, delete
  PersonaRowView.swift                 Row and favorite toggle
  PersonaDetailView.swift              Detail screen
  EditPersonaView.swift                Create and edit sheet
  AvatarImagePickerView.swift          Profile image sources
  ImagePicker.swift                    Camera picker
  PhotoPicker.swift                    Photo picker compiled into the target
  NetworkManager.swift                 Image download helper compiled into the target
  Extensions.swift                     UIImage helpers for CloudKit assets and rotation
  Extra Views (Delete Me)/
    GalleryImagePicker.swift           Older gallery picker, compiled into the target
    TestImagePicker.swift              Sample view, compiled into the target
```

`ViewModel.fetchImage` is the download used by AI Generated Random. `NetworkManager` is in Compile Sources and is not called by the views. Its URL path is `/imagezz`. No view presents `PhotoPicker`. `EditPersonaView` has a sheet for `GalleryImagePicker`, and no control in that view sets the sheet to visible. The gallery controls that are wired up are the `PhotosPicker` buttons.

## License

This repository has no license file.
