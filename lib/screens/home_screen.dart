import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';
import '../widgets/scan_history_card.dart';

/// Écran d'Accueil — main landing screen with scan button,
/// recent history, and sync status.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentScans = MockData.scanHistory.take(3).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SteriScan Reconstruct',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Traçabilité IA des kits chirurgicaux',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Primary Action ──────────────────────────────
                _PrimaryActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Scanner un Kit',
                  subtitle: 'Identifier les instruments par IA',
                  color: AppTheme.primaryIndigo,
                  onTap: () => context.go('/scan'),
                ),
                const SizedBox(height: 12),
                _PrimaryActionCard(
                  icon: Icons.autorenew_rounded,
                  title: 'Reconstituer un Kit',
                  subtitle: 'Guidage visuel étape par étape',
                  color: AppTheme.accentTeal,
                  onTap: () => context.go('/reconstitution'),
                ),
                const SizedBox(height: 28),

                // ── Sync Status ─────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.successGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Mode hors-ligne actif — Base locale synchronisée',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Recent Scans ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Derniers Scans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/history'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...recentScans.map(
                  (scan) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ScanHistoryCard(
                      result: scan,
                      onTap: () =>
                          context.go('/results?scanId=${scan.id}'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Quick Links ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _QuickLinkButton(
                        icon: Icons.history_rounded,
                        label: 'Historique',
                        onTap: () => context.go('/history'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickLinkButton(
                        icon: Icons.settings_rounded,
                        label: 'Paramètres',
                        onTap: () => context.go('/settings'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Footer ──────────────────────────────────────
                const Text(
                  'SteriScan Reconstruct v1.0\nConformité ISO 13485 | CE Mark | FDA Class II',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────

class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryIndigo, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
