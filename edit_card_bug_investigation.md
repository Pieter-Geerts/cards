```markdown
# Edit Card UI Update Bug Investigation

## Problem Description

When editing a card using the "Bewerken" option from the three dots menu, the changes aren't reflecting on the home page after saving.

## Analysis of Code Flow

### Expected Flow:

1. User taps three dots on card → shows bottom sheet
2. User taps "Bewerken" → navigates to EditCardPage
3. User edits values (title, description, etc.)
4. User taps save button → calls EditCardPage.\_save()
5. EditCardPage.\_save() calls widget.onSave(updatedCard)
6. HomePage's onSave callback updates database and calls widget.onUpdateCard
7. Main app's \_updateCard method updates \_cards list and calls setState
8. HomePage receives new cards and updates display

### Current Issue:

The updated values are not showing on the home page after save.

## Investigation Plan:

1. ✅ Check EditCardPage save method - looks correct
2. ✅ Check HomePage onSave callback - looks correct
3. ✅ Check main app \_updateCard method - looks correct
4. 🔍 Need to test the actual flow to identify where it breaks
5. 🔍 Check if there's a state sync issue between database and UI

## Test Results:

- Integration test passes, suggesting the basic flow works
- User reports the issue persists, indicating edge case or timing issue

## Next Steps:

1. Create a more comprehensive test that mimics user behavior exactly
2. Add debugging logs to trace the update flow
3. Check if the issue is specific to certain card types or fields
```
