import 'package:flutter/material.dart';

class AddCardBottomActions extends StatelessWidget {
  final int currentStep;
  final bool canProceed;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSave;

  const AddCardBottomActions({
    Key? key,
    required this.currentStep,
    required this.canProceed,
    required this.onCancel,
    required this.onBack,
    required this.onNext,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep == 0)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 2),
                    color: colorScheme.surface,
                  ),
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: theme.textTheme.bodyLarge?.color,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: theme.iconTheme.color?.withAlpha(230),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cancel',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (currentStep > 0)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 2),
                    color: colorScheme.surface,
                  ),
                  child: TextButton(
                    onPressed: onBack,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: theme.textTheme.bodyLarge?.color,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          color: theme.iconTheme.color?.withAlpha(230),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Back',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 16),

            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient:
                      canProceed
                          ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                          )
                          : null,
                  color: !canProceed ? theme.disabledColor.withAlpha(31) : null,
                  boxShadow:
                      canProceed
                          ? [
                            BoxShadow(
                              color: colorScheme.primary.withAlpha(51),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                          : null,
                ),
                child: ElevatedButton(
                  key:
                      currentStep == 2
                          ? const ValueKey('save_card_button')
                          : const ValueKey('next_button'),
                  onPressed:
                      canProceed ? (currentStep == 2 ? onSave : onNext) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentStep == 2 ? 'Save' : 'Next',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              canProceed
                                  ? colorScheme.onPrimary
                                  : theme.disabledColor.withAlpha(204),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (currentStep < 2 && canProceed) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                      if (currentStep == 2 && canProceed) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
