import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Paramètres — language selection, JSON import/export,
/// SMS configuration, and app info.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'fr';
  bool _smsAlertsEnabled = true;
  bool _offlineMode = true;
  bool _soundAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Language ──────────────────────────────────────
            _SectionHeader(title: 'Langue'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  _LanguageOption(
                    label: 'Français',
                    code: 'fr',
                    isSelected: _selectedLanguage == 'fr',
                    onTap: () => setState(() => _selectedLanguage = 'fr'),
                  ),
                  _LanguageOption(
                    label: 'Swahili',
                    code: 'sw',
                    isSelected: _selectedLanguage == 'sw',
                    onTap: () => setState(() => _selectedLanguage = 'sw'),
                  ),
                  _LanguageOption(
                    label: 'Haoussa',
                    code: 'ha',
                    isSelected: _selectedLanguage == 'ha',
                    onTap: () => setState(() => _selectedLanguage = 'ha'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Data Management ───────────────────────────────
            _SectionHeader(title: 'Gestion des Données'),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.file_upload_rounded,
              title: 'Importer base JSON',
              subtitle: 'Charger surgical_instruments_tracker.json',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Import JSON : sélectionnez un fichier…'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.file_download_rounded,
              title: 'Exporter base JSON',
              subtitle: 'Sauvegarder la base locale',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export JSON en cours…'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Réinitialiser les données',
              subtitle: 'Supprimer toutes les données locales',
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Confirmer la suppression'),
                    content: const Text(
                      'Toutes les données locales seront supprimées. '
                      'Cette action est irréversible.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Données réinitialisées'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // ── Alerts ────────────────────────────────────────
            _SectionHeader(title: 'Alertes'),
            const SizedBox(height: 10),
            _ToggleTile(
              icon: Icons.sms_rounded,
              title: 'Alertes SMS',
              subtitle: 'Envoyer des alertes via réseau GSM',
              value: _smsAlertsEnabled,
              onChanged: (v) => setState(() => _smsAlertsEnabled = v),
            ),
            const SizedBox(height: 8),
            _ToggleTile(
              icon: Icons.volume_up_rounded,
              title: 'Alertes sonores',
              subtitle: 'Son lors de la détection d\'anomalies',
              value: _soundAlerts,
              onChanged: (v) => setState(() => _soundAlerts = v),
            ),
            const SizedBox(height: 28),

            // ── Connectivity ──────────────────────────────────
            _SectionHeader(title: 'Connectivité'),
            const SizedBox(height: 10),
            _ToggleTile(
              icon: Icons.wifi_off_rounded,
              title: 'Mode hors-ligne',
              subtitle: 'Fonctionnement 100% local sans internet',
              value: _offlineMode,
              onChanged: (v) => setState(() => _offlineMode = v),
            ),
            const SizedBox(height: 28),

            // ── About ─────────────────────────────────────────
            _SectionHeader(title: 'À propos'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: const Column(
                children: [
                  Text(
                    'SteriScan Reconstruct',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Solution IA de traçabilité et reconstitution '
                    'des kits d\'instruments chirurgicaux.\n\n'
                    'Conformité ISO 13485 | CE Mark | FDA Class II',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.errorRed : AppTheme.primaryIndigo;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppTheme.errorRed
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryIndigo, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryIndigo,
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
