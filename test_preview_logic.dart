// Simple test script to verify the preview logic

void main() {
  // Test cases for _shouldShowPreview logic
  print('Testing preview visibility logic...');

  // Case 1: Empty fields - should NOT show preview
  print(
    'Test 1 (empty): ${shouldShowPreview("", "", false, false)} - Expected: false',
  );

  // Case 2: Short title - should NOT show preview
  print(
    'Test 2 (short title): ${shouldShowPreview("ab", "", false, false)} - Expected: false',
  );

  // Case 3: Good title but no extra content - should NOT show preview
  print(
    'Test 3 (title only): ${shouldShowPreview("test3", "", false, false)} - Expected: false',
  );

  // Case 4: Good title + description - should show preview
  print(
    'Test 4 (title + desc): ${shouldShowPreview("test3", "Some description", false, false)} - Expected: true',
  );

  // Case 5: Good title + logo - should show preview
  print(
    'Test 5 (title + logo): ${shouldShowPreview("test3", "", true, false)} - Expected: true',
  );

  // Case 6: Good title + icon - should show preview
  print(
    'Test 6 (title + icon): ${shouldShowPreview("test3", "", false, true)} - Expected: true',
  );

  // Case 7: Long meaningful title + description - should show preview
  print(
    'Test 7 (meaningful): ${shouldShowPreview("Starbucks Coffee", "Loyalty card", false, false)} - Expected: true',
  );
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
