import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rescue_map_placeholder.dart';
import '../../widgets/response_pulse.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/role_switch_banner.dart';
import '../timeline/incident_timeline_screen.dart';

class LiveResponseScreen extends StatefulWidget {
  final Incident incident;

  const LiveResponseScreen({super.key, required this.incident});

  @override
  State<LiveResponseScreen> createState() => _LiveResponseScreenState();
}

class _LiveResponseScreenState extends State<LiveResponseScreen> {
  void _requestBackup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _BackupRequestModal(
        incident: widget.incident,
        onRequest: (backupType) {
          final state = RescueScope.of(context);
          state.requestBackup(backupType);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.emergencyRed,
              content: Text('Backup Requested: $backupType unit alerted!'),
            ),
          );
        },
      ),
    );
  }

  void _markArrived(BuildContext context) {
    final state = RescueScope.of(context);
    state.markArrived();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.successGreen,
        content: Text('Status Updated: Responder arrived on scene!'),
      ),
    );
  }

  void _showResolutionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ResolutionModal(
        incident: widget.incident,
        onResolve: (notes) {
          final state = RescueScope.of(context);
          state.resolveIncident(notes);
          Navigator.pop(ctx);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => IncidentTimelineScreen(
                incident: widget.incident.copyWith(status: IncidentStatus.resolved),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showContactModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TACTICAL DISPATCH RADIO',
                style: TextStyle(
                  color: AppTheme.pulseCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Direct Tactical Comms Channel',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.radio_rounded, color: AppTheme.pulseCyan),
                ),
                title: const Text('Tactical Radio Frequency 148.55 MHz'),
                subtitle: const Text('Unit MED-01 (Medical Alpha)', style: TextStyle(color: AppTheme.textMuted)),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Simulated radio push-to-talk broadcast open.')),
                    );
                  },
                  child: const Text('CONNECT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    // Bind to live state if active, otherwise fallback to widget.incident
    final liveIncident = (state.activeIncident?.id == widget.incident.id)
        ? state.activeIncident!
        : (state.incidents.firstWhere(
            (i) => i.id == widget.incident.id,
            orElse: () => widget.incident,
          ));

    final isResolved = liveIncident.status == IncidentStatus.resolved;
    final isArrived = liveIncident.status == IncidentStatus.arrived;
    final isEnRoute = liveIncident.status == IncidentStatus.enRoute ||
        liveIncident.status == IncidentStatus.accepted ||
        liveIncident.status == IncidentStatus.assigned;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(liveIncident.id),
            const SizedBox(width: 8),
            SeverityBadge(severity: liveIncident.severity),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline_rounded, color: AppTheme.pulseCyan),
            tooltip: 'View Full Timeline',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => IncidentTimelineScreen(incident: liveIncident),
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Status Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            liveIncident.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(status: liveIncident.status),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // CORE UI CONCEPT: RESPONSE PULSE
                    ResponsePulse(
                      currentStatus: liveIncident.status,
                      severity: liveIncident.severity,
                      etaMinutes: isResolved ? 0 : 2,
                      distanceKm: isResolved ? 0.0 : 0.3,
                      matchScore: 96,
                    ),
                    const SizedBox(height: 14),

                    // MAP MODULE: Clean reusable placeholder widget
                    RescueMapPlaceholder(
                      incidentLocation: liveIncident.locationName,
                      responderLocation: 'Health Center, East Wing',
                      responderCallSign: 'MED-01',
                      etaMinutes: isResolved ? 0 : 2,
                      distanceKm: isResolved ? 0.0 : 0.3,
                      statusText: isResolved ? 'RESOLVED' : (isArrived ? 'ON SCENE' : 'EN ROUTE'),
                      height: 220,
                    ),
                    const SizedBox(height: 14),

                    // Response information card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.medical_services_rounded,
                                  color: AppTheme.emergencyRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      liveIncident.assignedResponderName ?? 'Medical Team Alpha',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Text(
                                      'Callsign: MED-01 • Trauma & CPR Lead',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.pulseCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '96% MATCH',
                                  style: TextStyle(
                                    color: AppTheme.pulseCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),

                          // Telemetry details (Wrapped so no overflow on 320px)
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _buildMiniInfo('STATUS', isResolved ? 'SCENE CLEAR' : (isArrived ? 'ON SCENE' : 'DISPATCHED')),
                              _buildMiniInfo('PEOPLE AFFECTED', '${liveIncident.peopleAffected} Person(s)'),
                              _buildMiniInfo('BACKUP CALLS', '${liveIncident.requestedBackups.length} Auxiliary'),
                            ],
                          ),
                          if (liveIncident.requestedBackups.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: liveIncident.requestedBackups.map((b) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emergencyRed.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.emergencyRed.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    'Backup: $b',
                                    style: const TextStyle(
                                      color: AppTheme.emergencyRed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tactical Action Panel
                    if (!isResolved) ...[
                      // First Row: Contact & Request Backup
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              text: 'COMMS RADIO',
                              icon: Icons.cell_tower_rounded,
                              isOutline: true,
                              height: 46,
                              onPressed: () => _showContactModal(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PrimaryButton(
                              text: 'REQUEST BACKUP',
                              icon: Icons.add_moderator_rounded,
                              isSecondary: true,
                              height: 46,
                              onPressed: () => _requestBackup(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Lifecycle Advancement Buttons
                      if (isEnRoute)
                        PrimaryButton(
                          text: 'RESPONDER ARRIVED ON SCENE',
                          icon: Icons.location_pin,
                          isDanger: false,
                          onPressed: () => _markArrived(context),
                        )
                      else if (isArrived)
                        PrimaryButton(
                          text: 'RESOLVE INCIDENT',
                          icon: Icons.verified_rounded,
                          isSuccess: true,
                          onPressed: () => _showResolutionModal(context),
                        ),
                    ] else ...[
                      // Resolved Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.successGreen, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'INCIDENT RESOLVED & ARCHIVED',
                                  style: TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              liveIncident.resolutionSummary ?? 'Area secured and medical care completed.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              text: 'VIEW COMPLETE INCIDENT TIMELINE',
                              icon: Icons.history_rounded,
                              height: 44,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => IncidentTimelineScreen(incident: liveIncident),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Request Backup Modal
class _BackupRequestModal extends StatefulWidget {
  final Incident incident;
  final ValueChanged<String> onRequest;

  const _BackupRequestModal({required this.incident, required this.onRequest});

  @override
  State<_BackupRequestModal> createState() => _BackupRequestModalState();
}

class _BackupRequestModalState extends State<_BackupRequestModal> {
  String _selectedBackup = 'Campus Security (Crowd Control)';

  final List<String> _options = [
    'Campus Security (Crowd Control)',
    'Trauma Medical Secondary Unit',
    'Fire Suppression & Hazmat',
    'Campus Facilities / Electrician',
    'Campus Police Armed Escort',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_moderator_rounded, color: AppTheme.emergencyRed),
                SizedBox(width: 10),
                Text(
                  'REQUEST AUXILIARY BACKUP',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Call additional specialized support units to current location.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),

            ..._options.map((opt) {
              final isSelected = _selectedBackup == opt;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedBackup = opt),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.emergencyRed : AppTheme.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppTheme.emergencyRed : AppTheme.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt,
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
            }),
            const SizedBox(height: 16),

            PrimaryButton(
              text: 'CONFIRM BACKUP DISPATCH',
              icon: Icons.send_rounded,
              isDanger: true,
              onPressed: () => widget.onRequest(_selectedBackup),
            ),
          ],
        ),
      ),
    );
  }
}

// Resolution Modal
class _ResolutionModal extends StatefulWidget {
  final Incident incident;
  final ValueChanged<String> onResolve;

  const _ResolutionModal({required this.incident, required this.onResolve});

  @override
  State<_ResolutionModal> createState() => _ResolutionModalState();
}

class _ResolutionModalState extends State<_ResolutionModal> {
  final TextEditingController _notesController = TextEditingController(
    text: 'Student treated for dehydration and light injury. Vitals normalized. Scene certified safe.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_rounded, color: AppTheme.successGreen),
                  SizedBox(width: 10),
                  Text(
                    'COMPLETE & RESOLVE INCIDENT',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Submit debrief notes to archive this emergency response on the campus grid.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),

              const Text(
                'RESOLUTION SUMMARY NOTES',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Enter clinical / security actions taken...',
                ),
              ),
              const SizedBox(height: 18),

              PrimaryButton(
                text: 'CONFIRM INCIDENT RESOLVED',
                icon: Icons.check_circle_rounded,
                isSuccess: true,
                onPressed: () => widget.onResolve(_notesController.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

