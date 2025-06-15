# Cards - QR Code Scanner & Manager

A Flutter application for scanning, storing, and managing QR codes and barcodes. This app allows users to scan codes using their device's camera and store the information locally for quick access later.

## Features

- Scan QR codes and barcodes using your device's camera
- Store scanned cards locally in a SQLite database
- View detailed information of each card including a generated QR code
- Offline functionality - no internet connection required
- Cross-platform support (Android, iOS)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.7.0 or higher)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [Git](https://git-scm.com/)

## Setting Up and Running the Project

### Clone the Repository

```bash
git clone https://github.com/Pieter-Geerts/cards.git
cd cards
```

### Install Dependencies

```bash
flutter pub get
```

### Running on Android Emulator

1. **Start an Android Emulator:**

   - Open Android Studio
   - Go to AVD Manager (Android Virtual Device Manager)
   - Create a new virtual device if you don't have one
   - Start the emulator

2. **Check Available Devices:**

   ```bash
   flutter devices
   ```

3. **Run the Application:**

   ```bash
   flutter run
   ```

   If you have multiple devices connected, specify the device:

   ```bash
   flutter run -d <device_id>
   ```

### Running on a Physical Android Device

1. Enable USB debugging on your device (Settings > Developer options)
2. Connect your device via USB
3. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart            # Application entry point
├── helpers/
│   └── database_helper.dart  # SQLite database management
├── models/
│   └── card_item.dart   # Data model for cards
└── pages/
    ├── home_page.dart        # Main screen with card list
    ├── card_detail_page.dart # Detailed view of a card
    └── add_card_page.dart    # Camera scanner for adding new cards
```

## Database Information

The app uses SQLite to store all cards locally on the device. The database structure is:

**Cards Table:**

- `id`: INTEGER (Primary Key)
- `title`: TEXT
- `description`: TEXT
- `name`: TEXT (Contains the scanned QR/barcode data)

## Editing Cards

You can edit a card's title and description by tapping the edit (pencil) icon on the card detail page. After saving, your changes will be persisted in the local database and reflected in the card list.

If you do not see your changes immediately, try returning to the main card list or restarting the app to refresh the view.

## Testing

Run the tests using:

```bash
flutter test
```

## Troubleshooting

### Camera Issues

- Ensure you have the proper permissions set in AndroidManifest.xml
- For Android 6.0+ (API 23+), the app will request camera permission at runtime
- If using an emulator, ensure it supports camera emulation or use a physical device

### Database Issues

- The database is created at first run
- If you need to reset the database, clear the app data or uninstall and reinstall

### Package Version Issues

If you encounter compatibility issues, verify your package versions in pubspec.yaml match the following:

- mobile_scanner: ^7.0.0
- qr_flutter: ^4.0.0
- sqflite: ^2.2.0
- path: ^1.8.3

## 📚 Documentation

For detailed documentation, development guides, and workflows, visit:

**[📖 Documentation Index](docs/README.md)**

### Quick Links:

- **[Release Guide](docs/guides/RELEASE.md)** - Complete release process
- **[Git Workflow](docs/workflows/GIT_WORKFLOW.md)** - Development workflow setup
- **[Scripts Documentation](scripts/README.md)** - Available automation scripts
- **[Dependency Management](docs/workflows/DEPENDENCY_MANAGEMENT.md)** - Managing dependencies

## Contributing

Contributions are welcome! Please start by reading our:

1. **[Git Workflow Guide](docs/workflows/GIT_WORKFLOW.md)** - Setup development environment
2. **[Release Guide](docs/guides/RELEASE.md)** - Understanding the release process

Feel free to submit a Pull Request following our workflow guidelines.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
