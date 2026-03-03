import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scan_result.dart';
import '../theme/app_theme.dart';

/// A card summarizing a past scan result for the history list.
class ScanHistoryCard extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onTap;

  const ScanHistoryCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isConformant = result.isConformant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isConformant
                    ? AppTheme.successGreen.withOpacity(0.1)
                    : AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isConformant
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color:
                    isConformant ? AppTheme.successGreen : AppTheme.errorRed,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.kitName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(result.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  if (result.operatorName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.operatorName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isConformant
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${result.conformityScore.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
