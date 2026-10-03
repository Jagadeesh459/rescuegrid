import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../state/rescue_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/role_switch_banner.dart';
import '../live_response/live_response_screen.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  String _activeFilter = 'ALL';

  final List<String> _filters = ['ALL', 'ACTIVE', 'RESOLVED', 'CRITICAL'];

  @override
  Widget build(BuildContext context) {
    final state = RescueScope.of(context);
    final allIncidents = state.incidents;

    final filtered = allIncidents.where((inc) {
      if (_activeFilter == 'ACTIVE') {
        return inc.status != IncidentStatus.resolved;
      }
      if (_activeFilter == 'RESOLVED') {
        return inc.status == IncidentStatus.resolved;
      }
      if (_activeFilter == 'CRITICAL') {
        return inc.severity == IncidentSeverity.critical;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Campus Incident Archive'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const RoleSwitchBanner(),
            // Filter Pills Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _activeFilter = filter),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (filter == 'CRITICAL'
                                    ? AppTheme.emergencyRed
                                    : AppTheme.pulseCyan)
                                : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppTheme.surfaceBorder,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.black : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // List of incidents
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No $_activeFilter incidents found',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final inc = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: IncidentCard(
                            incident: inc,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LiveResponseScreen(incident: inc),
                                ),
                              );
                            },
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

