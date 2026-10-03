import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_1/main.dart';
import 'package:flutter_1/state/rescue_state.dart';
import 'package:flutter_1/models/incident.dart';
import 'package:flutter_1/widgets/response_pulse.dart';
import 'package:flutter_1/widgets/rescue_map_placeholder.dart';

void main() {
  testWidgets('RescueGrid smoke test and brand identity', (WidgetTester tester) async {
    await tester.pumpWidget(const RescueGridApp());
    expect(find.text('RESCUEGRID'), findsOneWidget);
    expect(find.text('CAMPUS EMERGENCY RESPONSE'), findsOneWidget);
    // Advance timer so splash timer completes cleanly
    await tester.pump(const Duration(milliseconds: 2500));
  });

  testWidgets('Response Pulse renders all 7 emergency stages without overflow', (WidgetTester tester) async {
    // Test on extremely small screen (320 x 568 - iPhone SE 1st gen)
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                ResponsePulse(
                  currentStatus: IncidentStatus.enRoute,
                  severity: IncidentSeverity.critical,
                  etaMinutes: 2,
                  distanceKm: 0.4,
                  matchScore: 96,
                ),
                SizedBox(height: 10),
                RescueMapPlaceholder(
                  incidentLocation: 'CSE Block Lab 204',
                  responderLocation: 'Health Center East Wing',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Pump specific frame since ResponsePulse has continuous pulse animation
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('RESPONSE PULSE'), findsOneWidget);
    expect(find.text('EN ROUTE'), findsWidgets);
    expect(find.text('[ REAL MAP WILL BE INTEGRATED HERE ]'), findsOneWidget);
  });

  test('Local Deterministic Severity Analysis test', () {
    final state = RescueGridState();

    // Fire -> Critical
    final fireSev = state.analyzeSeverity(
      category: IncidentCategory.fire,
      peopleAffected: 1,
      description: 'Small flame near trash bin',
    );
    expect(fireSev, IncidentSeverity.critical);

    // Medical with trauma / unconscious keywords -> Critical
    final medCritSev = state.analyzeSeverity(
      category: IncidentCategory.medical,
      peopleAffected: 1,
      description: 'Student unconscious on floor with bleeding head',
    );
    expect(medCritSev, IncidentSeverity.critical);

    // Standard medical -> High
    final medHighSev = state.analyzeSeverity(
      category: IncidentCategory.medical,
      peopleAffected: 1,
      description: 'Sprained wrist while climbing stairs',
    );
    expect(medHighSev, IncidentSeverity.high);
  });

  test('Full emergency lifecycle simulation from creation to resolution and timeline', () {
    final state = RescueGridState();

    // 1. Student reports emergency
    final inc = state.createIncident(
      category: IncidentCategory.medical,
      peopleAffected: 2,
      description: 'Student collapsed unconscious with severe injury',
      locationName: 'CSE Block, Lab 204',
      landmark: 'Near AI Lab',
    );
    expect(inc.status, IncidentStatus.reported);
    expect(inc.severity, IncidentSeverity.critical);
    expect(state.activeIncident, isNotNull);

    // 2. Severity Assessment
    state.completeSeverityAssessment(IncidentSeverity.critical);
    expect(state.activeIncident!.status, IncidentStatus.assessed);

    // 3. Responder Ranking & Dispatch
    final ranked = state.rankResponders(IncidentCategory.medical);
    expect(ranked.isNotEmpty, isTrue);
    final topResponder = ranked.first;
    expect(topResponder.matchScore, greaterThan(80));

    state.assignResponder(topResponder);
    expect(state.activeIncident!.status, IncidentStatus.assigned);
    expect(state.activeIncident!.assignedResponderName, topResponder.name);

    // 4. Responder Accepts & Sets En Route
    state.acceptAssignment();
    expect(state.activeIncident!.status, IncidentStatus.accepted);

    state.setEnRoute();
    expect(state.activeIncident!.status, IncidentStatus.enRoute);

    // 5. Request Backup
    state.requestBackup('Trauma Care Auxiliary Unit');
    expect(state.activeIncident!.requestedBackups.length, 1);

    // 6. Arrival on scene
    state.markArrived();
    expect(state.activeIncident!.status, IncidentStatus.arrived);

    // 7. Resolution
    state.resolveIncident('Patient treated with oxygen and stabilized. Transported to health center.');
    expect(state.activeIncident, isNull);

    // Verify incident in history list is resolved and has full timeline
    final resolvedInList = state.incidents.firstWhere((i) => i.id == inc.id);
    expect(resolvedInList.status, IncidentStatus.resolved);
    expect(resolvedInList.timeline.length, greaterThanOrEqualTo(6));
  });
}
