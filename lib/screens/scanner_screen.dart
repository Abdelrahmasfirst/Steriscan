import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/mock_data.dart';
import '../models/models.dart';

/// Scanner & Capture screen — camera interface with overlay,
/// image upload simulation, and AI scan trigger.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _imageSelected = false;
  bool _isScanning = false;
  bool _scanComplete = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Selected kit for scanning
  String _selectedKitId = MockData.kits.first.id;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _simulateImageUpload() async {
    setState(() {
      _imageSelected = true;
      _scanComplete = false;
    });
  }

  Future<void> _startScan() async {
    if (!_imageSelected) return;

    setState(() => _isScanning = true);

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _scanComplete = true;
    });
  }

  void _viewResults() {
    final scanId = MockData.scanHistory.first.id;
    context.go('/results?scanId=$scanId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un Kit'),
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
            // ── Kit Selector ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kit de référence',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedKitId,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: MockData.kits.map((kit) {
                      return DropdownMenuItem(
                        value: kit.id,
                        child: Text(
                          '${kit.name} (${kit.totalInstruments} instr.)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedKitId = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Camera / Image Area ───────────────────────────
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: _imageSelected
                    ? AppTheme.primaryIndigo.withOpacity(0.05)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _imageSelected
                      ? AppTheme.primaryIndigo.withOpacity(0.3)
                      : AppTheme.borderLight,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: _imageSelected
                  ? _buildImagePreview()
                  : _buildCameraPlaceholder(),
            ),
            const SizedBox(height: 16),

            // ── Upload Button ─────────────────────────────────
            if (!_imageSelected)
              OutlinedButton.icon(
                onPressed: _simulateImageUpload,
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Choisir une image'),
              ),

            if (_imageSelected && !_scanComplete) ...[
              // ── Scan Button ───────────────────────────────────
              ElevatedButton(
                onPressed: _isScanning ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isScanning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Analyse IA en cours…'),
                        ],
                      )
                    : const Text('Démarrer le Scan IA'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _imageSelected = false;
                    _scanComplete = false;
                  });
                },
                child: const Text('Changer d\'image'),
              ),
            ],

            // ── Scanning Animation ────────────────────────────
            if (_isScanning) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigo.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.memory_rounded,
                              color: AppTheme.primaryIndigo,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Reconnaissance IA en cours…',
                      style: TextStyle(
                        color: AppTheme.primaryIndigo,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Identification des instruments chirurgicaux',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Scan Complete ─────────────────────────────────
            if (_scanComplete) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.successGreen.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successGreen,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan terminé !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${MockData.detectedInstruments.length} instruments détectés',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _viewResults,
                      child: const Text('Voir les Résultats'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _imageSelected = false;
                          _scanComplete = false;
                        });
                      },
                      child: const Text('Nouveau Scan'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Tips ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conseils pour un bon scan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  _TipRow(text: 'Bon éclairage, lumière uniforme'),
                  SizedBox(height: 6),
                  _TipRow(text: 'Instruments bien espacés sur le plateau'),
                  SizedBox(height: 6),
                  _TipRow(text: 'Photo prise à 30-40 cm de distance'),
                  SizedBox(height: 6),
                  _TipRow(text: 'Fond contrasté (bleu ou vert)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _pulseAnimation.value,
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Prenez une photo ou importez\nune image du kit',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.image_rounded,
              size: 56,
              color: AppTheme.primaryIndigo,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Image chargée avec succès',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryIndigo,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'kit_chirurgie_photo.jpg',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.accentTeal,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
