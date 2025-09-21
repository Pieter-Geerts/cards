import 'package:flutter/material.dart';

class AddCardLogoSelector extends StatelessWidget {
  final IconData? selectedLogoIcon;
  final VoidCallback onTap;

  const AddCardLogoSelector({
    super.key,
    required this.selectedLogoIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selectedLogoIcon != null
                  ? Theme.of(context).colorScheme.primary.withAlpha(25)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selectedLogoIcon != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
            width: selectedLogoIcon != null ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(10),
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
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(200),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text('Logo kiezen')),
                    Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
      ),
    );
  }
}
