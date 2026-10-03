import 'package:flutter/material.dart';
import '../state/rescue_scope.dart';
import '../state/rescue_state.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'student/student_dashboard.dart';
import 'responder/responder_dashboard.dart';
import 'admin/command_center_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController(text: 'STU-84920');
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role == UserRole.student) {
        _idController.text = 'STU-84920';
      } else if (role == UserRole.responder) {
        _idController.text = 'MED-01';
      } else {
        _idController.text = 'CMD-HQ';
      }
    });
  }

  void _proceed(RescueGridState state) {
    state.switchRole(_selectedRole);

    Widget target;
    switch (_selectedRole) {
      case UserRole.student:
        target = const StudentDashboard();
        break;
      case UserRole.responder:
        target = const ResponderDashboard();
        break;
      case UserRole.admin:
        target = const CommandCenterScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header branding
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.emergencyRed),
                    ),
                    child: const Center(
                      child: Icon(Icons.emergency_rounded, color: AppTheme.emergencyRed, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RESCUEGRID',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'CAMPUS DISPATCH SYSTEM',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Incident Access',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your role to access the live tactical emergency network.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Campus ID Input
              const Text(
                'CAMPUS ID / CALLSIGN',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.pulseCyan, size: 20),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'VERIFIED',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Role Selector Cards
              const Text(
                'SELECT DEMO ROLE',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              _buildRoleCard(
                role: UserRole.student,
                title: 'Student / Reporter',
                subtitle: 'Alex Rivera • Computer Science Block 3',
                badgeText: 'STUDENT PORTAL',
                icon: Icons.school_rounded,
                accentColor: AppTheme.infoBlue,
              ),
              const SizedBox(height: 12),

              _buildRoleCard(
                role: UserRole.responder,
                title: 'Emergency Responder',
                subtitle: 'Capt. David Miller • Medical Team Alpha',
                badgeText: 'DISPATCH UNIT',
                icon: Icons.medical_services_rounded,
                accentColor: AppTheme.emergencyRed,
              ),
              const SizedBox(height: 12),

              _buildRoleCard(
                role: UserRole.admin,
                title: 'Command Center',
                subtitle: 'Dispatcher Sarah Hayes • Central Operations HQ',
                badgeText: 'ADMIN / DISPATCH',
                icon: Icons.admin_panel_settings_rounded,
                accentColor: AppTheme.warningAmber,
              ),
              const SizedBox(height: 28),

              // Submit Button
              PrimaryButton(
                text: 'ENTER RESCUEGRID AS ${_selectedRole.title.toUpperCase()}',
                icon: Icons.login_rounded,
                isDanger: _selectedRole == UserRole.responder,
                onPressed: () => _proceed(state),
              ),
              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Hackathon Prototype Mode • No Cloud Backend Required',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedRole == role;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? accentColor : AppTheme.surfaceBorder,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onRoleChanged(role),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? accentColor : AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

