import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';

/// Reconstitution Guidée — step-by-step visual instructions
/// for reassembling a surgical kit.
class ReconstitutionScreen extends StatefulWidget {
  final String? kitId;

  const ReconstitutionScreen({super.key, this.kitId});

  @override
  State<ReconstitutionScreen> createState() => _ReconstitutionScreenState();
}

class _ReconstitutionScreenState extends State<ReconstitutionScreen> {
  int _currentStep = 0;
  final Set<int> _completedSteps = {};

  List<Map<String, String>> get _steps => MockData.reconstitutionSteps;

  bool get _allComplete => _completedSteps.length == _steps.length;

  void _markStepComplete(int index) {
    setState(() {
      _completedSteps.add(index);
      if (index < _steps.length - 1) {
        _currentStep = index + 1;
      }
    });
  }

  void _finishReconstitution() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppTheme.successGreen, size: 28),
            SizedBox(width: 10),
            Text('Reconstitution terminée'),
          ],
        ),
        content: const Text(
          'Le kit a été reconstitué avec succès. '
          'Effectuez un scan final pour valider la composition.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Accueil'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/scan');
            },
            child: const Text('Scan Final'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Resolve kit name
    final kit = widget.kitId != null
        ? MockData.kits.firstWhere(
            (k) => k.id == widget.kitId,
            orElse: () => MockData.kits.first,
          )
        : MockData.kits.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconstitution'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // ── Kit Info Bar ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: AppTheme.primaryIndigo.withOpacity(0.05),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kit.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${kit.totalInstruments} instruments • ${kit.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _allComplete
                        ? AppTheme.successGreen
                        : AppTheme.primaryIndigo,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_completedSteps.length}/${_steps.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress Bar ────────────────────────────────────
          LinearProgressIndicator(
            value: _steps.isEmpty
                ? 0
                : _completedSteps.length / _steps.length,
            backgroundColor: AppTheme.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              _allComplete ? AppTheme.successGreen : AppTheme.primaryIndigo,
            ),
            minHeight: 4,
          ),

          // ── Steps List ──────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isCompleted = _completedSteps.contains(index);
                final isCurrent = index == _currentStep;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StepCard(
                    stepNumber: step['step'] ?? '${index + 1}',
                    title: step['title'] ?? '',
                    description: step['description'] ?? '',
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    onComplete: isCompleted
                        ? null
                        : () => _markStepComplete(index),
                  ),
                );
              },
            ),
          ),

          // ── Bottom Action ───────────────────────────────────
          if (_allComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _finishReconstitution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Valider la Reconstitution'),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback? onComplete;

  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isCurrent,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.successGreen.withOpacity(0.05)
            : isCurrent
                ? AppTheme.primaryIndigo.withOpacity(0.05)
                : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppTheme.successGreen.withOpacity(0.3)
              : isCurrent
                  ? AppTheme.primaryIndigo.withOpacity(0.3)
                  : AppTheme.borderLight,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number / check
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.successGreen
                  : isCurrent
                      ? AppTheme.primaryIndigo
                      : AppTheme.textMuted.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20)
                  : Text(
                      stepNumber,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.textPrimary,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted
                        ? AppTheme.textMuted
                        : AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (!isCompleted && isCurrent) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Marquer comme fait'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
