import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/role_switch_banner.dart';
import 'report_flow/report_flow_screen.dart';
import '../live_response/live_response_screen.dart';
import '../history/incident_history_screen.dart';
import '../notifications/notification_center_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    final activeInc = state.activeIncident;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: AppTheme.emergencyRed, size: 20),
            SizedBox(width: 8),
            Text(
              'RESCUEGRID',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
                if (state.unreadNotificationCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.emergencyRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IncidentHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const RoleSwitchBanner(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campus Safety Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: activeInc != null
                            ? AppTheme.emergencyRed.withValues(alpha: 0.12)
                            : AppTheme.successGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeInc != null
                              ? AppTheme.emergencyRed.withValues(alpha: 0.5)
                              : AppTheme.successGreen.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeInc != null
                                  ? AppTheme.emergencyRed
                                  : AppTheme.successGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              activeInc != null
                                  ? 'CAMPUS ALERT: 1 ACTIVE INCIDENT IN PROGRESS'
                                  : 'CAMPUS STATUS: LEVEL 1 — ALL CLEAR',
                              style: TextStyle(
                                color: activeInc != null
                                    ? AppTheme.emergencyRed
                                    : AppTheme.successGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            activeInc != null ? 'ALERT' : 'NORMAL',
                            style: TextStyle(
                              color: activeInc != null
                                  ? AppTheme.emergencyRed
                                  : AppTheme.successGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Greeting
                    const Text(
                      'Welcome, Alex',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Direct line to campus police, trauma medical units, and rapid rescue.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // VISUALLY DOMINANT EMERGENCY CTA BUTTON (Hackathon Requirement)
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.emergencyRed
                                    .withValues(alpha: _glowAnimation.value),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Material(
                            color: AppTheme.emergencyRed,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ReportFlowScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.emergency_rounded,
                                        size: 44,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'REPORT EMERGENCY',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Instant GPS • Auto-Dispatch • Live Tracking',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Active Incident Alert Card (if any active incident exists)
                    if (activeInc != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ACTIVE INCIDENT IN PROGRESS',
                            style: TextStyle(
                              color: AppTheme.emergencyRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.emergencyRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PULSE LIVE',
                              style: TextStyle(
                                color: AppTheme.emergencyRed,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      IncidentCard(
                        incident: activeInc,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LiveResponseScreen(incident: activeInc),
                            ),
                          );
                        },
                        onLiveTrack: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LiveResponseScreen(incident: activeInc),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quick Actions
                    const Text(
                      'QUICK SAFETY SERVICES',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 10) / 2;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildQuickAction(
                              title: 'Campus Police',
                              subtitle: 'Ext. 911 / 24x7',
                              icon: Icons.local_police_rounded,
                              accentColor: AppTheme.infoBlue,
                              width: itemWidth,
                              onTap: () => _showQuickContact(context, 'Campus Police', '+1 (555) 019-9110'),
                            ),
                            _buildQuickAction(
                              title: 'Medical Clinic',
                              subtitle: 'Health Center',
                              icon: Icons.local_hospital_rounded,
                              accentColor: AppTheme.pulseCyan,
                              width: itemWidth,
                              onTap: () => _showQuickContact(context, 'Campus Medical Health Center', '+1 (555) 019-4321'),
                            ),
                            _buildQuickAction(
                              title: 'Night Escort',
                              subtitle: 'Safe walk service',
                              icon: Icons.nightlife_rounded,
                              accentColor: AppTheme.warningAmber,
                              width: itemWidth,
                              onTap: () => _showQuickContact(context, 'Student Night Safe Escort', '+1 (555) 019-3320'),
                            ),
                            _buildQuickAction(
                              title: 'Incident History',
                              subtitle: 'Past reports',
                              icon: Icons.fact_check_rounded,
                              accentColor: AppTheme.successGreen,
                              width: itemWidth,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const IncidentHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Recent Campus Incidents
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RECENT CAMPUS LOGS',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const IncidentHistoryScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'VIEW ALL',
                            style: TextStyle(
                              color: AppTheme.pulseCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // List of existing incidents
                    ...state.incidents.take(2).map((inc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IncidentCard(
                          incident: inc,
                          showTrackButton: inc.status != IncidentStatus.resolved,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LiveResponseScreen(incident: inc),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required double width,
    required VoidCallback onTap,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: accentColor),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickContact(BuildContext context, String service, String number) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Campus emergency direct hotline simulation.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded, color: AppTheme.pulseCyan),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('DIAL EMERGENCY CALL (SIMULATION)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.pulseCyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.surfaceLight,
                      content: Text('Simulated emergency call initiated to $service ($number)'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
