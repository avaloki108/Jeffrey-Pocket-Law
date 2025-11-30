import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  /// Announce text to screen readers
  void announce(String message) {
    SemanticsBinding.instance.sendSemanticsUpdate(
        AccessibilityAnnouncement(message, textDirection: TextDirection.ltr));
  }

  /// Create accessible button with proper semantics
  Widget buildAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String label,
    String? hint,
    bool excludeFromSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeFromSemantics,
      button: true,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 44), // WCAG touch target size
        ),
        child: child,
      ),
    );
  }

  /// Create accessible text field
  Widget buildAccessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 16), // Minimum readable font size
      ),
    );
  }

  /// Wrap content with live region for dynamic updates
  Widget buildLiveRegion({
    required Widget child,
    required String announcement,
  }) {
    return Semantics(liveRegion: true, label: announcement, child: child);
  }

  /// Check if high contrast mode should be used
  Future<bool> shouldUseHighContrast(BuildContext context) async {
    final brightness = MediaQuery.of(context).platformBrightness;
    // In a real implementation, check system accessibility settings
    return brightness == Brightness.dark;
  }

  /// Get appropriate font size based on accessibility preferences
  double getAccessibleFontSize(BuildContext context, {double baseSize = 16}) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;

    // Ensure minimum readable size
    return textScaler.scale(baseSize).clamp(14.0, 24.0);
  }

  /// Create focusable widget with custom focus behavior
  Widget buildFocusableWidget({
    required Widget child,
    required FocusNode focusNode,
    VoidCallback? onFocusChange,
  }) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        onFocusChange?.call();
        if (hasFocus) {
          announce('Focused on ${focusNode.debugLabel ?? 'item'}');
        }
      },
      child: child,
    );
  }

  /// Handle keyboard navigation
  void handleKeyboardNavigation({
    required BuildContext context,
    required FocusNode currentFocus,
    FocusNode? nextFocus,
    FocusNode? previousFocus,
  }) {
    // This would be enhanced with actual keyboard event handling
    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }
}
