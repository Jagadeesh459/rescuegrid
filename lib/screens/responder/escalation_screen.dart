import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'responder_dashboard.dart';

class EscalationScreen extends StatefulWidget {
  final Incident incident;

  const EscalationScreen({super.key, required this.incident});

  @override
  State<EscalationScreen> createState() => _EscalationScreenState();
}

class _EscalationScreenState extends State<EscalationScreen> {
  String _selectedReason = 'Already handling critical incident';
  bool _isEscalating = false;
  bool _isTransferred = false;
  String _newResponderName = '';

  final List<String> _reasons = [
    'Already handling critical incident',
    'Outside current team skill specialization',
    'Unable to respond / transport maintenance',
    'Stationed outside minimum response radius',
    'Other operational conflict',
  ];

  void _triggerEscalation() async {
    setState(() {
      _isEscalating = true;
    });

    final state = RescueScope.of(context);
    await Future.delayed(const Duration(milliseconds: 1400));

    state.escalateAndReassign(_selectedReason);

    final updated = state.activeIncident;
    setState(() {
      _isEscalating = false;
      _isTransferred = true;
      _newResponderName = updated?.assignedResponderName ?? 'Campus Security Bravo';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Decline & Escalation Protocol'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isTransferred && !_isEscalating) ...[
                const Text(
                  'Reason for Declining',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Command Center requires immediate justification to trigger automatic fallback dispatch.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: _reasons.length,
                    itemBuilder: (context, index) {
                      final r = _reasons[index];
                      final isSelected = _selectedReason == r;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selectedReason = r),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.warningAmber : AppTheme.surfaceBorder,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? AppTheme.warningAmber : AppTheme.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    r,
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                PrimaryButton(
                  text: 'CONFIRM & TRIGGER ESCALATION',
                  icon: Icons.alt_route_rounded,
                  isDanger: true,
                  onPressed: _triggerEscalation,
                ),
              ] else if (_isEscalating) ...[
                const Spacer(),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warningAmber),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ESCALATING TO COMMAND CENTER...',
                        style: TextStyle(
                          color: AppTheme.warningAmber,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Finding next qualified responder with lowest ETA on campus grid...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ] else ...[
                // Transferred success state
                const Spacer(),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.successGreen, width: 2),
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 54),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ASSIGNMENT TRANSFERRED',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Incident ${widget.incident.id} successfully rerouted to $_newResponderName.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Text(
                          'Declined Reason Logged: "$_selectedReason"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'RETURN TO RESPONDER DASHBOARD',
                  icon: Icons.dashboard_rounded,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const ResponderDashboard()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

