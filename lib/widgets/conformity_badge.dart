import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Displays a conformity score as a colored badge.
class ConformityBadge extends StatelessWidget {
  final double score;
  final double size;

  const ConformityBadge({
    super.key,
    required this.score,
    this.size = 80,
  });

  Color get _color {
    if (score >= 90) return AppTheme.successGreen;
    if (score >= 70) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  String get _label {
    if (score >= 90) return 'Conforme';
    if (score >= 70) return 'Partiel';
    return 'Non conforme';
  }

  IconData get _icon {
    if (score >= 90) return Icons.check_circle_rounded;
    if (score >= 70) return Icons.warning_rounded;
    return Icons.cancel_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            '${score.toStringAsFixed(0)}% – $_label',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
