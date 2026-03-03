import 'package:flutter/material.dart';
import '../models/instrument.dart';
import '../theme/app_theme.dart';

/// A small colored chip indicating instrument status.
class StatusChip extends StatelessWidget {
  final InstrumentStatus status;

  const StatusChip({super.key, required this.status});

  Color get _backgroundColor {
    switch (status) {
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

  String get _label {
    switch (status) {
      case InstrumentStatus.present:
        return 'Présent';
      case InstrumentStatus.missing:
        return 'Manquant';
      case InstrumentStatus.extra:
        return 'Surplus';
      case InstrumentStatus.damaged:
        return 'Endommagé';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
