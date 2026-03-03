import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';
import '../models/models.dart';
import '../widgets/scan_history_card.dart';

/// Historique & Rapports — scan journal with timestamps,
/// filtering, and export capabilities.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all'; // 'all', 'conformant', 'non_conformant'

  List<ScanResult> get _filteredScans {
    final scans = MockData.scanHistory;
    switch (_filter) {
      case 'conformant':
        return scans.where((s) => s.isConformant).toList();
      case 'non_conformant':
        return scans.where((s) => !s.isConformant).toList();
      default:
        return scans;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scans = _filteredScans;
    final totalScans = MockData.scanHistory.length;
    final conformantCount =
        MockData.scanHistory.where((s) => s.isConformant).length;
    final conformityRate = totalScans > 0
        ? (conformantCount / totalScans * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique & Rapports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_rounded),
            tooltip: 'Exporter',
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Export $value en cours…'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'PDF',
                child: Text('Exporter en PDF'),
              ),
              const PopupMenuItem(
                value: 'CSV',
                child: Text('Exporter en CSV'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Statistics Bar ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.primaryIndigo.withOpacity(0.04),
            child: Row(
              children: [
                _StatBubble(
                  value: totalScans.toString(),
                  label: 'Total Scans',
                  color: AppTheme.primaryIndigo,
                ),
                const SizedBox(width: 12),
                _StatBubble(
                  value: conformantCount.toString(),
                  label: 'Conformes',
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: 12),
                _StatBubble(
                  value: '$conformityRate%',
                  label: 'Taux',
                  color: AppTheme.accentTeal,
                ),
              ],
            ),
          ),

          // ── Filter Chips ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tous',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Conformes',
                  isSelected: _filter == 'conformant',
                  onTap: () => setState(() => _filter = 'conformant'),
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Anomalies',
                  isSelected: _filter == 'non_conformant',
                  onTap: () => setState(() => _filter = 'non_conformant'),
                  color: AppTheme.errorRed,
                ),
              ],
            ),
          ),

          // ── Scan List ───────────────────────────────────────
          Expanded(
            child: scans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 56, color: AppTheme.textMuted.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucun scan trouvé',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: scans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final scan = scans[index];
                      return ScanHistoryCard(
                        result: scan,
                        onTap: () =>
                            context.go('/results?scanId=${scan.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBubble({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryIndigo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
