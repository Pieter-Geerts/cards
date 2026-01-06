# Add Card Flow Restructuring

## Overview
The add card flow has been restructured to provide a better user experience by:
1. **First showing a selection screen** where users choose how they want to add a card
2. **Then executing the selected flow** with automatic code detection
3. **Finally showing the card details form** with the code pre-filled

## New Flow Architecture

### Selection Screen (`AddCardEntryPage`)
The main entry point now shows three options:

#### Option 1: Scan with Camera (Primary)
- User taps "Scan Barcode" (camera icon)
- Opens `CameraScanPage` with camera feed
- User scans a code with the device camera
- Code is automatically detected and the type (QR vs Barcode) is determined
- User is taken to the form page with code pre-filled

#### Option 2: Import from Image (Secondary)
- User taps "Import from Image" (image icon)
- Opens image picker to select an image from gallery
- `ImageScanPage` is shown with the selected image
- Google ML Kit automatically scans the image for codes
- User can confirm or edit the detected code
- Once saved, user is taken to the form page with code pre-filled

#### Option 3: Manual Entry (Secondary)
- User taps "Manual Entry" (edit icon)
- Skips all scanning and goes directly to the card details form
- Code field is empty and user types it manually

## Technical Changes

### Modified Files

#### 1. `lib/pages/add_card_entry_page.dart`
**Changes:**
- Converted from `StatelessWidget` to `StatefulWidget` to handle async operations
- Restructured navigation methods to support the new flow:
  - `_navigateToCameraScan()` - Opens camera, waits for scan result, then navigates to form with code
  - `_navigateToImageScan()` - Picks image, opens image scan page, waits for result, then navigates to form with code
  - `_navigateToManualForm()` - Directly opens form without code
  - `_navigateToFormWithCode()` - Helper to navigate to form with pre-filled code and type

**Navigation Pattern:**
```
User Selection
    ↓
[Camera Scan | Image Picker | Direct Form]
    ↓
[Get Code Result]
    ↓
AddCardFormPage with pre-filled code
```

#### 2. `lib/pages/add_card_form_page.dart`
**Changes:**
- Added `scannedType` parameter to the constructor
- Updated `_initializeForm()` to use `scannedType` if provided, otherwise auto-detect

**Constructor:**
```dart
const AddCardFormPage({
  required this.mode,
  this.scannedCode,
  this.scannedType,  // NEW: Optional auto-detected type
});
```

#### 3. `lib/pages/camera_scan_page.dart`
**No changes** - Already compatible with new flow

#### 4. `lib/pages/image_scan_page.dart`
**No changes** - Already compatible with new flow (has `onCodeEntered` callback)

## Data Flow

### Camera Flow
```
AddCardEntryPage
  ↓
CameraScanPage
  ├─ Detects code
  ├─ Determines format (QR or Barcode)
  └─ Calls onCodeScanned(code, type)
      └─ Pops with (code, type) tuple
        └─ AddCardEntryPage receives result
          └─ _navigateToFormWithCode()
            └─ AddCardFormPage with:
                - scannedCode: code
                - scannedType: type
                - mode: AddCardMode.scan
```

### Image Flow
```
AddCardEntryPage
  ↓
ImageScanHelper.pickAndScanImage()
  ├─ Opens image picker
  └─ Returns imagePath
    └─ ImageScanPage(imagePath)
      ├─ Auto-scans image with ML Kit
      ├─ User reviews/edits code
      └─ Calls onCodeEntered(code, type)
        └─ Pops with (code, type) tuple
          └─ AddCardEntryPage receives result
            └─ _navigateToFormWithCode()
              └─ AddCardFormPage with:
                  - scannedCode: code
                  - scannedType: type
                  - mode: AddCardMode.scan
```

### Manual Flow
```
AddCardEntryPage
  ↓
_navigateToManualForm()
  └─ AddCardFormPage with:
      - mode: AddCardMode.manual
      - scannedCode: null
      - scannedType: null
```

## Benefits

1. **Clearer User Journey** - Users see all options upfront
2. **Intelligent Auto-fill** - Code is pre-filled when available
3. **Type Detection** - Card type (QR vs Barcode) is automatically detected
4. **Flexibility** - Users can choose their preferred method
5. **Reduced Steps** - Manual entry skips unnecessary scan pages

## Code Pre-filling Logic

When code is scanned (from camera or image):
1. The detected code is passed to `AddCardFormPage`
2. `AddCardFormPage._initializeForm()` sets `_codeController.text = scannedCode`
3. If `scannedType` is provided, it's used directly
4. If `scannedType` is null, it's auto-detected based on code characteristics
5. The form shows the pre-filled code and type, allowing users to edit if needed

## Error Handling

- **Image Pick Cancelled**: If user cancels image picker, nothing happens
- **No Code Found**: If ML Kit doesn't find a code in image, user can still manual edit
- **Navigation Guards**: All async operations check `mounted` before using context
- **Context Safety**: Ignore directives for `use_build_context_synchronously` are properly placed

## Localization

All UI strings are already localized:
- `scanBarcodeCTA` - Camera scan button
- `useCameraToScan` - Camera scan subtitle
- `importFromImage` - Image import button
- `scanFromImageSubtitle` - Image import subtitle
- `manualEntryFull` - Manual entry button
- `typeCodeManually` - Manual entry subtitle
- `or` - Divider text

## Testing Scenarios

1. **Camera Scan Happy Path**
   - Tap camera button → scan QR code → see form with code filled

2. **Image Scan Happy Path**
   - Tap image button → select image → auto-scan → form with code filled

3. **Manual Entry**
   - Tap manual button → form opens empty → user types code

4. **User Cancels**
   - At any scan page, user can cancel → returns to entry page

5. **Code Not Found**
   - Image selected but no code found → user can still type manually in image scan page
