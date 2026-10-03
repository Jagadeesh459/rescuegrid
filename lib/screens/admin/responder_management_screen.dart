import 'package:flutter/material.dart';
import '../../models/responder.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_switch_banner.dart';

class ResponderManagementScreen extends StatelessWidget {
  const ResponderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    final responders = state.responders;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Responder Fleet Management'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const RoleSwitchBanner(),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: responders.length,
                itemBuilder: (context, index) {
                  final r = responders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shield_rounded, color: AppTheme.pulseCyan, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            r.name,
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
                                        Text(
                                          '(${r.callSign})',
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${r.type.label} • ${r.locationName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              // Workload Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LOAD: ${r.workload}',
                                  style: const TextStyle(
                                    color: AppTheme.pulseCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Skills Tags (Wrap for responsiveness)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: r.skills.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              );
                            }).toList(),
                          ),
                          const Divider(),

                          // Status Selector Row (Responsive Wrap)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'FLEET STATUS:',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              ...ResponderAvailability.values.map((status) {
                                final isCurrent = r.availability == status;
                                Color color;
                                switch (status) {
                                  case ResponderAvailability.available:
                                    color = AppTheme.successGreen;
                                    break;
                                  case ResponderAvailability.busy:
                                    color = AppTheme.warningAmber;
                                    break;
                                  case ResponderAvailability.offline:
                                    color = AppTheme.textMuted;
                                    break;
                                }

                                return InkWell(
                                  onTap: () {
                                    state.updateResponderAvailability(r.id, status);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCurrent ? color.withValues(alpha: 0.15) : AppTheme.surfaceLight,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isCurrent ? color : AppTheme.surfaceBorder,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          status.label,
                                          style: TextStyle(
                                            color: isCurrent ? color : AppTheme.textSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
