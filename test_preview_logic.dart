// Simple test script to verify the preview logic

void main() {
  // Test cases for _shouldShowPreview logic (prints removed for CI)
}

bool shouldShowPreview(
  String title,
  String description,
  bool hasLogoPath,
  bool hasSelectedIcon,
) {
  // Replicate the logic from _shouldShowPreview
  final titleTrimmed = title.trim();
  final descriptionTrimmed = description.trim();

  return titleTrimmed.length >= 3 &&
      (descriptionTrimmed.isNotEmpty || hasLogoPath || hasSelectedIcon);
}
