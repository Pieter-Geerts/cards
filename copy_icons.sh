#!/bin/bash

# Set source and destination directories
SOURCE_DIR="/Users/pietergeerts/Prive/cards/AppIcons/Android"
DEST_BASE_DIR="/Users/pietergeerts/Prive/cards/android/app/src/main/res"

# Array of densities
DENSITIES=("mdpi" "hdpi" "xhdpi" "xxhdpi" "xxxhdpi")

# Array of icon files to copy
ICON_FILES=("ic_launcher.png" "ic_launcher_round.png" "ic_launcher_foreground.png" "ic_launcher_background.png")

# Copy each icon file for each density
for density in "${DENSITIES[@]}"; do
  echo "Processing $density icons..."
  
  # Create destination directory if it doesn't exist
  mkdir -p "$DEST_BASE_DIR/mipmap-$density"
  
  # Copy each icon file
  for icon in "${ICON_FILES[@]}"; do
    if [ -f "$SOURCE_DIR/mipmap-$density/$icon" ]; then
      cp "$SOURCE_DIR/mipmap-$density/$icon" "$DEST_BASE_DIR/mipmap-$density/$icon"
      echo "  Copied $icon to mipmap-$density"
    else
      echo "  Warning: $icon not found in $SOURCE_DIR/mipmap-$density"
    fi
  done
done

# Check for and copy adaptive icon XML file
if [ -f "$SOURCE_DIR/mipmap-anydpi-v26/ic_launcher.xml" ]; then
  mkdir -p "$DEST_BASE_DIR/mipmap-anydpi-v26"
  cp "$SOURCE_DIR/mipmap-anydpi-v26/ic_launcher.xml" "$DEST_BASE_DIR/mipmap-anydpi-v26/ic_launcher.xml"
  echo "Copied adaptive icon XML file"
fi

if [ -f "$SOURCE_DIR/mipmap-anydpi-v26/ic_launcher_round.xml" ]; then
  mkdir -p "$DEST_BASE_DIR/mipmap-anydpi-v26"
  cp "$SOURCE_DIR/mipmap-anydpi-v26/ic_launcher_round.xml" "$DEST_BASE_DIR/mipmap-anydpi-v26/ic_launcher_round.xml"
  echo "Copied round adaptive icon XML file"
fi

echo "Icon copying completed!"
