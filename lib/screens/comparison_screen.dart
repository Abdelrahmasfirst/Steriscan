import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';
import '../models/models.dart';

/// Comparaison & Alertes — side-by-side reference vs actual,
/// with missing instruments in red and surplus in orange.
class ComparisonScreen extends StatelessWidget {
  final String? scanId;

  const ComparisonScreen({super.key, this.scanId});

  @override
  Widget build(BuildContext context) {
    final result = scanId != null
        ? MockData.scanHistory.firstWhere(
            (s) => s.id == scanId,
            orElse: () => MockData.scanHistory.first,
          )
        : MockData.scanHistory.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparaison'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/results?scanId=${result.id}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Text(
                    result.kitName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(
                        color: AppTheme.successGreen,
                        label: 'Présent',
                      ),
                      const SizedBox(width: 16),
                      _LegendDot(
                        color: AppTheme.errorRed,
                        label: 'Manquant',
                      ),
                      const SizedBox(width: 16),
                      _LegendDot(
                        color: AppTheme.warningOrange,
                        label: 'Surplus',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Column Headers ────────────────────────────────
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Référence',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Détecté',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Comparison Rows ───────────────────────────────
            ...List.generate(
              result.referenceInstruments.length,
              (index) {
                final ref = result.referenceInstruments[index];
                // Find matching detected instrument
                final detected = result.detectedInstruments.firstWhere(
                  (d) => d.id == ref.id,
                  orElse: () => Instrument(
                    id: ref.id,
                    name: ref.name,
                    status: InstrumentStatus.missing,
                    confidenceScore: 0.0,
                  ),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ComparisonRow(
                    reference: ref,
                    detected: detected,
                  ),
                );
              },
            ),

            // ── Extra instruments (not in reference) ──────────
            ...result.detectedInstruments
                .where((d) => d.status == InstrumentStatus.extra)
                .map(
                  (extra) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ComparisonRow(
                      reference: null,
                      detected: extra,
                    ),
                  ),
                ),

            const SizedBox(height: 24),

            // ── Actions ───────────────────────────────────────
            if (result.missingInstruments.isNotEmpty ||
                result.extraInstruments.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorRed.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_rounded,
                            color: AppTheme.errorRed, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Anomalies détectées',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (result.missingInstruments.isNotEmpty)
                      Text(
                        '${result.missingInstruments.length} instrument(s) manquant(s)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    if (result.extraInstruments.isNotEmpty)
                      Text(
                        '${result.extraInstruments.length} instrument(s) en surplus',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton(
              onPressed: () =>
                  context.go('/reconstitution?kitId=${result.kitId}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lancer la Reconstitution'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final Instrument? reference;
  final Instrument detected;

  const _ComparisonRow({
    this.reference,
    required this.detected,
  });

  Color get _rowBorderColor {
    switch (detected.status) {
      case InstrumentStatus.present:
        return AppTheme.successGreen.withOpacity(0.3);
      case InstrumentStatus.missing:
        return AppTheme.errorRed.withOpacity(0.3);
      case InstrumentStatus.extra:
        return AppTheme.warningOrange.withOpacity(0.3);
      case InstrumentStatus.damaged:
        return AppTheme.errorRed.withOpacity(0.3);
    }
  }

  Color get _rowBgColor {
    switch (detected.status) {
      case InstrumentStatus.present:
        return Colors.white;
      case InstrumentStatus.missing:
        return AppTheme.errorRed.withOpacity(0.04);
      case InstrumentStatus.extra:
        return AppTheme.warningOrange.withOpacity(0.04);
      case InstrumentStatus.damaged:
        return AppTheme.errorRed.withOpacity(0.04);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rowBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rowBorderColor),
      ),
      child: Row(
        children: [
          // Reference side
          Expanded(
            child: reference != null
                ? _InstrumentMini(
                    name: reference!.name,
                    id: reference!.id,
                    color: AppTheme.textPrimary,
                  )
                : const Center(
                    child: Text(
                      '—',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),

          // Status icon in center
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _statusIcon(),
          ),

          // Detected side
          Expanded(
            child: _InstrumentMini(
              name: detected.name,
              id: detected.id,
              color: _statusTextColor(),
              suffix: detected.status == InstrumentStatus.extra
                  ? ' (surplus)'
                  : detected.status == InstrumentStatus.missing
                      ? ' (absent)'
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon() {
    switch (detected.status) {
      case InstrumentStatus.present:
        return const Icon(Icons.check_circle_rounded,
            color: AppTheme.successGreen, size: 22);
      case InstrumentStatus.missing:
        return const Icon(Icons.cancel_rounded,
            color: AppTheme.errorRed, size: 22);
      case InstrumentStatus.extra:
        return const Icon(Icons.add_circle_rounded,
            color: AppTheme.warningOrange, size: 22);
      case InstrumentStatus.damaged:
        return const Icon(Icons.error_rounded,
            color: AppTheme.errorRed, size: 22);
    }
  }

  Color _statusTextColor() {
    switch (detected.status) {
      case InstrumentStatus.present:
        return AppTheme.textPrimary;
      case InstrumentStatus.missing:
        return AppTheme.errorRed;
      case InstrumentStatus.extra:
        return AppTheme.warningOrange;
      case InstrumentStatus.damaged:
        return AppTheme.errorRed;
    }
  }
}

class _InstrumentMini extends StatelessWidget {
  final String name;
  final String id;
  final Color color;
  final String? suffix;

  const _InstrumentMini({
    required this.name,
    required this.id,
    required this.color,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name + (suffix ?? ''),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          id,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
