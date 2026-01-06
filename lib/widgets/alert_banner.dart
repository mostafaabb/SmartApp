import 'package:flutter/material.dart';
import '../core/themes/app_colors.dart';

class AlertBanner extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? AppColors.warning.withOpacity(0.1);
    final txtColor = textColor ?? AppColors.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: txtColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: txtColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon ?? Icons.warning_amber_rounded,
              color: txtColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: txtColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message ?? 'You have active alerts to review',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: txtColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: txtColor.withOpacity(0.6),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
