import 'package:flutter/material.dart';
import '../models/instrument.dart';
import '../theme/app_theme.dart';
import 'status_chip.dart';

/// A list tile displaying an instrument with its detection status.
class InstrumentTile extends StatelessWidget {
  final Instrument instrument;
  final bool showConfidence;
  final VoidCallback? onTap;

  const InstrumentTile({
    super.key,
    required this.instrument,
    this.showConfidence = true,
    this.onTap,
  });

  Color get _statusColor {
    switch (instrument.status) {
      case InstrumentStatus.present:
        return AppTheme.successGreen;
      case InstrumentStatus.missing:
        return AppTheme.errorRed;
      case InstrumentStatus.extra:
        return AppTheme.warningOrange;
      case InstrumentStatus.damaged:
        return AppTheme.errorRed;
    }
  }

  IconData get _statusIcon {
    switch (instrument.status) {
      case InstrumentStatus.present:
        return Icons.check_circle_rounded;
      case InstrumentStatus.missing:
        return Icons.cancel_rounded;
      case InstrumentStatus.extra:
        return Icons.add_circle_rounded;
      case InstrumentStatus.damaged:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Instrument info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instrument.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${instrument.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Confidence + status chip
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: instrument.status),
                if (showConfidence && instrument.confidenceScore > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${(instrument.confidenceScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _statusColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
