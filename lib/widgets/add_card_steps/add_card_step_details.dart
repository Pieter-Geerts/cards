import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AddCardStepDetails extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final IconData? selectedLogoIcon;
  final VoidCallback onLogoTap;
  final bool shouldShowPreview;
  final Widget? previewWidget;

  const AddCardStepDetails({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedLogoIcon,
    required this.onLogoTap,
    required this.shouldShowPreview,
    this.previewWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fillColor =
        theme.inputDecorationTheme.fillColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).title + ' *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).companyOrNameLabel,
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).optionalDescription,
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  AppLocalizations.of(context).logoLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onLogoTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          selectedLogoIcon != null
                              ? colorScheme.primary.withAlpha(25)
                              : fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            selectedLogoIcon != null
                                ? colorScheme.primary
                                : theme.dividerColor,
                        width: selectedLogoIcon != null ? 2 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withAlpha(10),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child:
                        selectedLogoIcon != null
                            ? Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(selectedLogoIcon, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: Text('Logo geselecteerd')),
                                Icon(Icons.arrow_forward_ios, size: 20),
                              ],
                            )
                            : Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: colorScheme.surfaceContainerHighest,
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: theme.colorScheme.onSurface
                                        .withAlpha(200),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context).selectALogo,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 20),
                              ],
                            ),
                  ),
                ),
                if (shouldShowPreview && previewWidget != null) ...[
                  const SizedBox(height: 32),
                  previewWidget!,
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
