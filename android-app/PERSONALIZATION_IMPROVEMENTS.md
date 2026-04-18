# Personalization Architecture Improvements

## Summary
Unified personalization data management with comprehensive validation, error handling, Mixpanel tracking, and legacy migration support.

## Changes Made

### 1. New Files Created

#### `lib/data/personalization_service.dart`
- **PersonalizationService**: Service class for managing user personalization data
  - Cached data management for performance
  - Legacy format migration from individual storage keys
  - Input validation and sanitization
  - Mixpanel event tracking for all personalization actions
  - Field-specific updates (`updateFields()`)
  - Clear data functionality
  - Error handling with Mixpanel error tracking

- **PersonalizationNotifier**: StateNotifier for reactive personalization updates
  - Async data loading with proper states
  - Save, update, reload, and clear operations
  - Convenience methods for common updates

### 2. Files Modified

#### `lib/presentation/providers.dart`
- Added `personalizationServiceProvider` - Provides the PersonalizationService
- Added `personalizationProvider` - StateNotifierProvider with AsyncValue
- Added `personalizationDataProvider` - Convenience provider for sync access
- Added `isPersonalizedProvider` - Quick check for completion status
- **Kept legacy providers** (`userNameProvider`, `lawyerNameProvider`, etc.) for backward compatibility

#### `lib/presentation/personalize_screen.dart`
- Updated `_save()` to use `PersonalizationData` model
- Uses `personalizationProvider.notifier` to save data
- Shows error snackbar if save fails
- Cleaner, more maintainable code

#### `lib/presentation/splash_screen.dart`
- Updated `_navigateNext()` to use `PersonalizationService`
- Automatically migrates legacy data to new format
- Updates both legacy and new providers for compatibility

#### `lib/data/rag_repository.dart`
- Added `performRAGQueryWithPersonalization()` method
- Accepts `PersonalizationData` directly for cleaner usage
- Maintains backward compatibility with existing method

## Features Implemented

### ✅ Unified Data Model
- Single source of truth for personalization
- Type-safe with compile-time guarantees
- Default values for all fields
- `copyWith` method for immutability

### ✅ Validation
- User name: max 50 characters, cannot be empty for completion
- Lawyer name: max 50 characters, defaults to "Jeffrey"
- Age range: must be from predefined list
- Use cases: validated against known use case IDs

### ✅ Mixpanel Tracking
Events tracked:
- `Personalization Loaded`
- `Personalization Saved`
- `Personalization Validation Failed`
- `Personalization Save Error`
- `Personalization Load Error`
- `Personalization Update Error`
- `Personalization Cleared`
- `Personalization Clear Error`

User properties set:
- `user_name`
- `age_range`
- `use_cases`
- `lawyer_name`
- `personalization_completed`

### ✅ Legacy Migration
- Automatically migrates data from old individual keys
- Seamless upgrade path for existing users
- Supports both formats during transition period

### ✅ Error Handling
- Graceful degradation on errors
- Returns default data if loading fails
- Tracks all errors in Mixpanel
- User-friendly error messages

## Usage Examples

### Saving Personalization
```dart
final data = PersonalizationData(
  userName: 'John',
  lawyerName: 'Jeffrey',
  ageRange: '25-34',
  useCases: ['housing', 'employment'],
  isCompleted: true,
);
await ref.read(personalizationProvider.notifier).save(data);
```

### Updating Individual Fields
```dart
await ref.read(personalizationProvider.notifier).updateUserName('Jane');
await ref.read(personalizationProvider.notifier).updateLawyerName('Counselor');
```

### Reading Personalization
```dart
// Watch for changes
final data = ref.watch(personalizationDataProvider);

// Check if personalized
final isPersonalized = ref.watch(isPersonalizedProvider);

// Access individual fields (legacy, still works)
final userName = ref.watch(userNameProvider);
```

### Using in RAG Queries
```dart
final result = await ragRepository.performRAGQueryWithPersonalization(
  prompt,
  state,
  personalization: personalizationData,
);
```

## Migration Path

### For New Code
Use the new `personalizationProvider` and `PersonalizationData` model:

```dart
final personalization = ref.watch(personalizationDataProvider);
final notifier = ref.read(personalizationProvider.notifier);
```

### For Existing Code
Legacy providers (`userNameProvider`, `lawyerNameProvider`, etc.) are kept for backward compatibility. They are automatically synced with the new provider.

## Storage Format

### New Format (JSON)
```
{
  "userName": "John",
  "lawyerName": "Jeffrey",
  "ageRange": "25-34",
  "useCases": "housing,employment",
  "isCompleted": true,
  "updatedAt": "2026-04-17T12:00:00.000Z"
}
```

### Legacy Format (Individual Keys)
- `user_name`: "John"
- `lawyer_name`: "Jeffrey"
- `user_age_range`: "25-34"
- `user_use_cases`: "housing,employment"
- `personalized`: "true"

Both formats are supported. Legacy is automatically migrated on first load.

## Testing Recommendations

1. **Test legacy migration**: Install old version, personalize, then update to new version
2. **Test validation**: Try invalid data (empty names, bad age ranges, etc.)
3. **Test Mixpanel events**: Verify all events are tracked correctly
4. **Test error handling**: Disable storage and verify graceful degradation
5. **Test backward compatibility**: Ensure existing screens still work

## Future Improvements

1. Add more use case options
2. Add user preferences (theme, notification settings, etc.)
3. Add profile picture support
4. Add user onboarding completion tracking
5. Add A/B testing for personalization prompts
