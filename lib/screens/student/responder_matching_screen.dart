import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../models/responder.dart';
import '../../state/rescue_scope.dart';
import '../../state/rescue_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responder_card.dart';
import '../live_response/live_response_screen.dart';
import '../responder/new_assignment_screen.dart';

class ResponderMatchingScreen extends StatefulWidget {
  final Incident incident;

  const ResponderMatchingScreen({super.key, required this.incident});

  @override
  State<ResponderMatchingScreen> createState() => _ResponderMatchingScreenState();
}

class _ResponderMatchingScreenState extends State<ResponderMatchingScreen> {
  bool _isAutoDispatched = false;
  Responder? _topResponder;
  List<Responder> _rankedResponders = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runMatching();
    });
  }

  void _runMatching() async {
    final state = RescueScope.of(context);
    final ranked = state.rankResponders(widget.incident.category);

    setState(() {
      _rankedResponders = ranked;
      _topResponder = ranked.isNotEmpty ? ranked.first : null;
    });

    // Simulate short auto-dispatch delay
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted && _topResponder != null) {
      state.assignResponder(_topResponder!);
      setState(() {
        _isAutoDispatched = true;
      });
    }
  }

  void _goToStudentLiveTrack() {
    final state = RescueScope.of(context);
    final active = state.activeIncident ?? widget.incident;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LiveResponseScreen(incident: active),
      ),
    );
  }

  void _switchAndAcceptAsResponder() {
    final state = RescueScope.of(context);
    state.switchRole(UserRole.responder);
    final active = state.activeIncident ?? widget.incident;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => NewAssignmentScreen(incident: active),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Response Intelligence'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Algorithm Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.pulseCyan.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.pulseCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.hub_rounded, color: AppTheme.pulseCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEIGHTED MATCHING MATRIX',
                            style: TextStyle(
                              color: AppTheme.pulseCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Skill fit (40%) • ETA (30%) • Availability (20%) • Load (10%)',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Auto-Dispatch Status Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isAutoDispatched
                      ? AppTheme.emergencyRed.withValues(alpha: 0.15)
                      : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isAutoDispatched
                        ? AppTheme.emergencyRed
                        : AppTheme.surfaceBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAutoDispatched
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_top_rounded,
                      color: _isAutoDispatched ? AppTheme.emergencyRed : AppTheme.warningAmber,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isAutoDispatched
                            ? 'OPTIMAL RESPONDER DISPATCHED'
                            : 'EVALUATING ACTIVE UNITS...',
                        style: TextStyle(
                          color: _isAutoDispatched
                              ? AppTheme.emergencyRed
                              : AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    if (_isAutoDispatched)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.emergencyRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ALERT SENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'RANKED RESPONDERS (CAMPUS RADAR)',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // List of ranked responders
              Expanded(
                child: _rankedResponders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _rankedResponders.length,
                        itemBuilder: (context, index) {
                          final responder = _rankedResponders[index];
                          final isTop = index == 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Stack(
                              children: [
                                ResponderCard(
                                  responder: responder,
                                  isSelected: isTop && _isAutoDispatched,
                                  actionLabel: isTop ? 'ASSIGNED' : null,
                                ),
                                if (isTop)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.pulseCyan,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '#1 RANKED',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Actions (2 paths for seamless hackathon demo)
              if (_isAutoDispatched) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'TRACK RESPONSE LIVE (STUDENT VIEW)',
                  icon: Icons.radar_rounded,
                  onPressed: _goToStudentLiveTrack,
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  text: 'SWITCH TO RESPONDER & ACCEPT ORDER',
                  icon: Icons.assignment_turned_in_rounded,
                  isSecondary: true,
                  onPressed: _switchAndAcceptAsResponder,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
