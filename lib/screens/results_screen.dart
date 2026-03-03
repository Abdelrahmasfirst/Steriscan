import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// Résultats de Scan — displays detected instruments with status,
/// confidence scores, and conformity badge.
class ResultsScreen extends StatelessWidget {
  final String? scanId;

  const ResultsScreen({super.key, this.scanId});

  @override
  Widget build(BuildContext context) {
    // Resolve scan result from mock data
    final result = scanId != null
        ? MockData.scanHistory.firstWhere(
            (s) => s.id == scanId,
            orElse: () => MockData.scanHistory.first,
          )
        : MockData.scanHistory.first;

    final presentCount =
        result.detectedInstruments.where((i) => i.status == InstrumentStatus.present).length;
    final missingCount =
        result.detectedInstruments.where((i) => i.status == InstrumentStatus.missing).length;
    final extraCount =
        result.detectedInstruments.where((i) => i.status == InstrumentStatus.extra).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats du Scan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded),
            tooltip: 'Comparaison',
            onPressed: () => context.go('/comparison?scanId=${result.id}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Conformity Score ───────────────────────────────
            Center(
              child: ConformityBadge(score: result.conformityScore),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                result.isConformant
                    ? 'Kit conforme ✅'
                    : result.conformityScore >= 70
                        ? 'Kit partiellement conforme ⚠️'
                        : 'Kit non conforme ❌',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Summary Stats ─────────────────────────────────
            Row(
              children: [
                _StatCard(
                  label: 'Présents',
                  count: presentCount,
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Manquants',
                  count: missingCount,
                  color: AppTheme.errorRed,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Surplus',
                  count: extraCount,
                  color: AppTheme.warningOrange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Kit Info ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.kitName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${result.kitId}  •  Scan: ${result.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  if (result.operatorName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Opérateur: ${result.operatorName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Instruments List ──────────────────────────────
            const Text(
              'Instruments Détectés',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...result.detectedInstruments.map(
              (instrument) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InstrumentTile(instrument: instrument),
              ),
            ),
            const SizedBox(height: 24),

            // ── Actions ───────────────────────────────────────
            ElevatedButton(
              onPressed: () =>
                  context.go('/comparison?scanId=${result.id}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Voir la Comparaison'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export PDF en cours…'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Export PDF'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Composition sauvegardée'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Sauvegarder'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () =>
                  context.go('/reconstitution?kitId=${result.kitId}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reconstituer le Kit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
