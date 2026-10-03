import 'package:flutter/material.dart';
import '../state/rescue_scope.dart';
import '../state/rescue_state.dart';
import '../theme/app_theme.dart';

class RoleSwitchBanner extends StatelessWidget {
  const RoleSwitchBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    final role = state.currentRole;

    Color badgeColor;
    IconData roleIcon;
    switch (role) {
      case UserRole.student:
        badgeColor = AppTheme.infoBlue;
        roleIcon = Icons.school_rounded;
        break;
      case UserRole.responder:
        badgeColor = AppTheme.emergencyRed;
        roleIcon = Icons.medical_services_rounded;
        break;
      case UserRole.admin:
        badgeColor = AppTheme.warningAmber;
        roleIcon = Icons.admin_panel_settings_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF090D13),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(roleIcon, size: 14, color: badgeColor),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ROLE: ${role.title.toUpperCase()}',
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${role.badgeId})',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  role.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Role switch action button
          InkWell(
            onTap: () => _showRoleSwitchSheet(context, state),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 13, color: AppTheme.pulseCyan),
                  SizedBox(width: 4),
                  Text(
                    'SWITCH',
                    style: TextStyle(
                      color: AppTheme.pulseCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleSwitchSheet(BuildContext context, RescueGridState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SELECT DEMO PERSPECTIVE',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Experience the emergency workflow across all stakeholder viewpoints.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ...UserRole.values.map((r) {
                  final isSelected = state.currentRole == r;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        state.switchRole(r);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.pulseCyan.withValues(alpha: 0.12)
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.pulseCyan
                                : AppTheme.surfaceBorder,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              r == UserRole.student
                                  ? Icons.school_rounded
                                  : (r == UserRole.responder
                                      ? Icons.medical_services_rounded
                                      : Icons.admin_panel_settings_rounded),
                              color: isSelected
                                  ? AppTheme.pulseCyan
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.title,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppTheme.pulseCyan
                                          : AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${r.userName} • ID: ${r.badgeId}',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.pulseCyan, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

