import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'responder_matching_screen.dart';

class SeverityAnalysisScreen extends StatefulWidget {
  final Incident incident;

  const SeverityAnalysisScreen({super.key, required this.incident});

  @override
  State<SeverityAnalysisScreen> createState() => _SeverityAnalysisScreenState();
}

class _SeverityAnalysisScreenState extends State<SeverityAnalysisScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = true;
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  final List<String> _factorsChecked = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _runFactorSimulation();
  }

  void _runFactorSimulation() async {
    final factors = [
      'Evaluating Category: ${widget.incident.category.label}',
      'Parsing Impact Count: ${widget.incident.peopleAffected} Person(s)',
      'Checking Location Risk: ${widget.incident.locationName}',
      'Scanning Triage Keywords: "${widget.incident.description}"',
      'Assessing Response Time Factor (<3 min goal)',
    ];

    for (int i = 0; i < factors.length; i++) {
      await Future.delayed(const Duration(milliseconds: 320));
      if (mounted) {
        setState(() {
          _factorsChecked.add(factors[i]);
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      final state = RescueScope.of(context);
      state.completeSeverityAssessment(widget.incident.severity);

      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _proceedToMatching() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResponderMatchingScreen(incident: widget.incident),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final severity = widget.incident.severity;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.analytics_outlined, size: 14, color: AppTheme.pulseCyan),
                        const SizedBox(width: 6),
                        Text(
                          widget.incident.id,
                          style: const TextStyle(
                            color: AppTheme.pulseCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'DETERMINISTIC TRIAGE ENGINE',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isAnalyzing
                            ? 'Analyzing Emergency...'
                            : 'Severity Assessed',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isAnalyzing
                            ? 'Calculating tactical priority via rule-based campus emergency factors.'
                            : 'Deterministic classification calculated. Auto-dispatch protocol ready.',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Animation Center Graphic
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isAnalyzing
                                      ? AppTheme.pulseCyan.withValues(alpha: 0.1)
                                      : severity.color.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: _isAnalyzing
                                        ? AppTheme.pulseCyan
                                        : severity.color,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isAnalyzing ? AppTheme.pulseCyan : severity.color)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _isAnalyzing
                                        ? Icons.radar_rounded
                                        : Icons.priority_high_rounded,
                                    size: 54,
                                    color: _isAnalyzing ? AppTheme.pulseCyan : severity.color,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Result Card when analysis complete
                      if (!_isAnalyzing) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: severity.color.withValues(alpha: 0.8),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: severity.color.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'PRIORITY LEVEL: ${severity.label}',
                                  style: TextStyle(
                                    color: severity.color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                severity.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Immediate siren response and medical/security intercept activated.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Factors Evaluated Checklist
                      const Text(
                        'FACTORS EVALUATED',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ..._factorsChecked.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppTheme.pulseCyan, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    f,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_isAnalyzing && _factorsChecked.length < 5) ...[
                        const SizedBox(height: 12),
                        const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pulseCyan),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Button
              if (!_isAnalyzing) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'PROCEED TO MATCHING ENGINE',
                  icon: Icons.hub_rounded,
                  isDanger: severity == IncidentSeverity.critical,
                  onPressed: _proceedToMatching,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

