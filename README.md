# BabyCare App 🍼

[![Build and Deploy](https://github.com/dhiviyalakshmi-a/Baby-Care/actions/workflows/build-and-deploy.yml/badge.svg)](https://github.com/dhiviyalakshmi-a/Baby-Care/actions/workflows/build-and-deploy.yml)
[![Release](https://github.com/dhiviyalakshmi-a/Baby-Care/actions/workflows/release.yml/badge.svg)](https://github.com/dhiviyalakshmi-a/Baby-Care/actions/workflows/release.yml)

A simple, privacy-first Flutter app to track your baby's feeding, urination, and stool patterns. Designed with a clean, friendly UI, it helps new parents monitor their baby's health without compromising on data privacy. All data is stored locally on your device.

---

## ✨ Features

- **🍼 Feeding Timer**: Start and stop a timer to accurately track feeding durations.
- **💧 One-Tap Logging**: Quickly log urination and stool events with a single tap.
- **📖 Daily History**: View a chronological list of all events for any given day.
- **✏️ Edit & Delete**: Easily correct or remove entries from the history.
- **⏰ Smart Reminders**: Get notifications 2 and 3 hours after the last feeding.
- **📤 Data Export**: Export daily history to a human-readable text file to share with doctors.
- **💖 Privacy-First**: All data is stored locally on your device. No cloud sync, no accounts.
- **📱 iOS Live Activities & Dynamic Island**: Monitor the feeding timer directly from your lock screen or Dynamic Island on supported iPhones.
- **🤖 Android Quick Settings Tile**: Start and stop feeding directly from the Android Quick Settings panel.
- **🌐 Multi-platform**: Built with Flutter for Android, iOS, and Web.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Local Storage**: [path_provider](https://pub.dev/packages/path_provider) for file-based storage.
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **CI/CD**: [GitHub Actions](https://github.com/features/actions)

---

## 🚀 Getting Started

Follow these instructions to get the project up and running on your local machine.

### Prerequisites

- **Flutter SDK**: Make sure you have the Flutter SDK installed. See the [official guide](https://flutter.dev/docs/get-started/install).
- **Git**: To clone the repository.
- **ImageMagick** (Optional): The asset download script uses ImageMagick to generate placeholder icons. If not installed, it will create simple text placeholders instead.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/dhiviyalakshmi-a/Baby-Care.git
    cd Baby-Care
    ```

2.  **Download Required Fonts:**
    This project uses the Nunito font, which must be downloaded manually and placed in the `assets/fonts/Nunito/` directory.
    - Go to Nunito on Google Fonts.
    - Click "Get font" and then "Download all".
    - Unzip the file and copy `Nunito-Regular.ttf`, `Nunito-Bold.ttf`, and `Nunito-Light.ttf` into `assets/fonts/Nunito/`.

3.  **Set up placeholder assets:**
    Run the asset script to verify fonts and create placeholders for other assets.
    ```sh
    # Make the script executable
    chmod +x scripts/download_assets.sh

    # Run the script
    ./scripts/download_assets.sh
    ```

4.  **Get dependencies:**
    ```sh
    flutter pub get
    ```

5.  **Run the app:**
    ```sh
    flutter run
    ```

---

## 📦 Building for Production (Android)

Here’s how to build the Android APK and App Bundle (AAB) for release.

### 1. Create a Keystore

If you don't have one, create a signing key using `keytool`.

```sh
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias <your-key-alias>
```

Place the generated `keystore.jks` file inside the `android/app/` directory.

### 2. Create `key.properties`

Create a file named `key.properties` inside the `android/` directory. This file is included in `.gitignore` to keep your credentials safe.

Add the following content to `android/key.properties`, replacing the placeholder values with your actual credentials:

```properties
storeFile=keystore.jks
keyAlias=<your-key-alias>
storePassword=<your-store-password>
keyPassword=<your-key-password>
```

### 3. Build the App

You can now build the release versions of the app.

#### Build APK

This command creates a set of APKs for different device architectures.

```sh
flutter build apk --release --split-per-abi
```

The output files will be in `build/app/outputs/flutter-apk/`.

#### Build App Bundle (AAB)

This command creates an AAB file, which is the required format for publishing on the Google Play Store.

```sh
flutter build appbundle --release
```

The output file will be in `build/app/outputs/bundle/release/`.

### Using the Build Script

Alternatively, you can use the provided build script for a more automated process:

```sh
./scripts/build_scripts.sh android release
```

This will run the build commands and copy the artifacts to the `build_output/` directory.

---

## 📜 Available Scripts

- `scripts/download_assets.sh`: Downloads the Nunito font family and creates placeholder icons and illustrations. This is required for the initial project setup.
- `scripts/build_scripts.sh`: A comprehensive script to build the app for various platforms (Android, iOS, Web, etc.). Usage: `./scripts/build_scripts.sh [platform] [build_type]`.

---

## ⚙️ CI/CD

This project uses **GitHub Actions** for automated testing and building.

- **`build-and-deploy.yml`**: Runs on every push/PR to `main` and `develop`. It tests, analyzes, and builds the app for Android, iOS, and Web. It also deploys the web version to GitHub Pages.
- **`release.yml`**: Triggers on new version tags (e.g., `v1.2.3`) to create a GitHub Release and attach the compiled APK and AAB files as release artifacts.

---

## 🤝 Contributing

Contributions are welcome! If you have a feature request, bug report, or want to contribute code, please feel free to open an issue or submit a pull request.

## 📄 License

This project is open-source. Please see the `LICENSE` file for more details.