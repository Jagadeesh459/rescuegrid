import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../models/responder.dart';
import '../models/notification_item.dart';
import '../models/timeline_event.dart';
import '../data/mock_data.dart';

enum UserRole {
  student('Student', 'Alex Rivera', 'STU-84920'),
  responder('Responder', 'Capt. David Miller', 'MED-01'),
  admin('Command Center', 'Dispatcher Sarah Hayes', 'CMD-HQ');

  final String title;
  final String userName;
  final String badgeId;
  const UserRole(this.title, this.userName, this.badgeId);
}

class RescueGridState extends ChangeNotifier {
  UserRole _currentRole = UserRole.student;
  UserRole get currentRole => _currentRole;

  List<Incident> _incidents = [];
  List<Incident> get incidents => _incidents;

  List<Responder> _responders = [];
  List<Responder> get responders => _responders;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  ResponderAvailability _responderDutyStatus = ResponderAvailability.available;
  ResponderAvailability get responderDutyStatus => _responderDutyStatus;

  Incident? _activeIncident;
  Incident? get activeIncident => _activeIncident;

  int _incidentCounter = 2042;

  RescueGridState() {
    _responders = List.from(MockData.initialResponders);
    _incidents = List.from(MockData.initialIncidents);
    _notifications = List.from(MockData.initialNotifications);
  }

  void switchRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void setResponderDuty(ResponderAvailability status) {
    _responderDutyStatus = status;
    notifyListeners();
  }

  void updateResponderAvailability(String responderId, ResponderAvailability status) {
    _responders = _responders.map((item) {
      if (item.id == responderId) {
        return item.copyWith(availability: status);
      }
      return item;
    }).toList();
    notifyListeners();
  }

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  // Local Deterministic Severity Analysis
  IncidentSeverity analyzeSeverity({
    required IncidentCategory category,
    required int peopleAffected,
    required String description,
  }) {
    final text = description.toLowerCase();

    // Critical conditions
    if (category == IncidentCategory.fire) return IncidentSeverity.critical;
    
    if (category == IncidentCategory.medical) {
      if (peopleAffected >= 2 ||
          text.contains('unconscious') ||
          text.contains('bleeding') ||
          text.contains('cardiac') ||
          text.contains('chest') ||
          text.contains('collapse') ||
          text.contains('breath') ||
          text.contains('severe') ||
          text.contains('trauma')) {
        return IncidentSeverity.critical;
      }
      return IncidentSeverity.high;
    }

    if (category == IncidentCategory.security) {
      if (text.contains('weapon') ||
          text.contains('assault') ||
          text.contains('intruder') ||
          text.contains('threat') ||
          peopleAffected >= 2) {
        return IncidentSeverity.critical;
      }
      return IncidentSeverity.high;
    }

    if (category == IncidentCategory.hazard) {
      if (text.contains('gas') ||
          text.contains('chemical') ||
          text.contains('explosion') ||
          text.contains('wire')) {
        return IncidentSeverity.critical;
      }
      return IncidentSeverity.high;
    }

    if (category == IncidentCategory.accident) {
      if (peopleAffected >= 3) return IncidentSeverity.critical;
      if (peopleAffected >= 1) return IncidentSeverity.high;
      return IncidentSeverity.medium;
    }

    if (category == IncidentCategory.infrastructure) {
      if (text.contains('elevator') || text.contains('collapse')) {
        return IncidentSeverity.high;
      }
      return IncidentSeverity.medium;
    }

    return IncidentSeverity.medium;
  }

  // Local Responder Ranking Algorithm
  List<Responder> rankResponders(IncidentCategory category) {
    final list = _responders.map((r) {
      // 1. Skill match percentage
      int skillMatch = 50;
      switch (category) {
        case IncidentCategory.medical:
          if (r.type == ResponderType.medical) {
            skillMatch = 98;
          } else if (r.type == ResponderType.rapid) {
            skillMatch = 75;
          } else {
            skillMatch = 45;
          }
          break;
        case IncidentCategory.fire:
        case IncidentCategory.hazard:
          if (r.type == ResponderType.fire) {
            skillMatch = 96;
          } else if (r.type == ResponderType.rapid) {
            skillMatch = 65;
          } else {
            skillMatch = 40;
          }
          break;
        case IncidentCategory.security:
          if (r.type == ResponderType.security) {
            skillMatch = 96;
          } else if (r.type == ResponderType.rapid) {
            skillMatch = 80;
          } else {
            skillMatch = 50;
          }
          break;
        default:
          skillMatch = 75;
      }

      // 2. Distance & ETA factor (0 - 100)
      final etaScore = (100 - (r.etaMinutes * 10)).clamp(20, 100);

      // 3. Availability factor
      final availScore = r.availability == ResponderAvailability.available
          ? 100
          : (r.availability == ResponderAvailability.busy ? 30 : 0);

      // 4. Workload factor
      final workloadScore = (100 - (r.workload * 35)).clamp(10, 100);

      // Weighted Total: 40% Skills + 30% ETA + 20% Availability + 10% Workload
      final totalScore = ((skillMatch * 0.40) +
              (etaScore * 0.30) +
              (availScore * 0.20) +
              (workloadScore * 0.10))
          .round()
          .clamp(10, 99);

      return r.copyWith(
        skillMatchPercent: skillMatch,
        matchScore: totalScore,
      );
    }).toList();

    // Sort descending by match score
    list.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return list;
  }

  // Create & start reporting incident
  Incident createIncident({
    required IncidentCategory category,
    required int peopleAffected,
    required String description,
    required String locationName,
    required String landmark,
    String? photoAsset,
  }) {
    final severity = analyzeSeverity(
      category: category,
      peopleAffected: peopleAffected,
      description: description,
    );

    final id = 'INC-$_incidentCounter';
    _incidentCounter++;

    final now = DateTime.now();
    final newIncident = Incident(
      id: id,
      category: category,
      severity: severity,
      description: description.isEmpty ? 'Emergency reported by student' : description,
      peopleAffected: peopleAffected,
      locationName: locationName,
      landmark: landmark,
      photoAsset: photoAsset,
      status: IncidentStatus.reported,
      reporterName: _currentRole.userName,
      reporterId: _currentRole.badgeId,
      createdAt: now,
      updatedAt: now,
      timeline: [
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-1',
          timestamp: now,
          title: 'Emergency Reported',
          description: '$id submitted from $locationName ($landmark)',
          stage: 'reported',
          isHighlight: true,
        ),
      ],
    );

    _activeIncident = newIncident;
    _incidents.insert(0, newIncident);

    _addNotification(
      title: 'Emergency Reported: $id',
      message: 'New ${category.label} report at $locationName',
      priority: severity == IncidentSeverity.critical
          ? NotificationPriority.critical
          : NotificationPriority.warning,
      incidentId: id,
    );

    notifyListeners();
    return newIncident;
  }

  void completeSeverityAssessment(IncidentSeverity severity) {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-2',
          timestamp: now,
          title: 'Severity Assessed',
          description: 'Classified as ${severity.label} priority. Automated dispatch activated.',
          stage: 'assessed',
          isHighlight: severity == IncidentSeverity.critical,
        ),
      );

    _activeIncident = _activeIncident!.copyWith(
      severity: severity,
      status: IncidentStatus.assessed,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    _updateIncidentInList(_activeIncident!);
    notifyListeners();
  }

  void assignResponder(Responder responder) {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-3',
          timestamp: now,
          title: 'Responder Auto-Dispatched',
          description: 'Assigned to ${responder.name} (${responder.callSign}) [Match Score: ${responder.matchScore}%]',
          stage: 'assigned',
        ),
      );

    _activeIncident = _activeIncident!.copyWith(
      status: IncidentStatus.assigned,
      assignedResponderId: responder.id,
      assignedResponderName: responder.name,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    // Update responder workload
    _responders = _responders.map((r) {
      if (r.id == responder.id) {
        return r.copyWith(workload: r.workload + 1, availability: ResponderAvailability.busy);
      }
      return r;
    }).toList();

    _updateIncidentInList(_activeIncident!);

    _addNotification(
      title: 'Response Dispatched: ${_activeIncident!.id}',
      message: 'Unit ${responder.callSign} assigned to ${_activeIncident!.locationName}',
      priority: NotificationPriority.info,
      incidentId: _activeIncident!.id,
    );

    notifyListeners();
  }

  void acceptAssignment() {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-4',
          timestamp: now,
          title: 'Assignment Accepted',
          description: '${_activeIncident!.assignedResponderName} acknowledged dispatch order',
          stage: 'accepted',
          isHighlight: true,
        ),
      );

    _activeIncident = _activeIncident!.copyWith(
      status: IncidentStatus.accepted,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    _updateIncidentInList(_activeIncident!);

    _addNotification(
      title: 'Responder En Route to ${_activeIncident!.id}',
      message: '${_activeIncident!.assignedResponderName} accepted the call.',
      priority: NotificationPriority.info,
      incidentId: _activeIncident!.id,
    );

    notifyListeners();
  }

  void setEnRoute() {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-5',
          timestamp: now,
          title: 'En Route with Siren',
          description: 'Emergency vehicle tracking live towards ${_activeIncident!.locationName}',
          stage: 'enRoute',
        ),
      );

    _activeIncident = _activeIncident!.copyWith(
      status: IncidentStatus.enRoute,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    _updateIncidentInList(_activeIncident!);
    notifyListeners();
  }

  void markArrived() {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-6',
          timestamp: now,
          title: 'Responder On-Scene',
          description: '${_activeIncident!.assignedResponderName} arrived at ${_activeIncident!.locationName}',
          stage: 'arrived',
          isHighlight: true,
        ),
      );

    _activeIncident = _activeIncident!.copyWith(
      status: IncidentStatus.arrived,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    _updateIncidentInList(_activeIncident!);

    _addNotification(
      title: 'Responder Arrived: ${_activeIncident!.id}',
      message: 'Unit reached scene. Response operation underway.',
      priority: NotificationPriority.success,
      incidentId: _activeIncident!.id,
    );

    notifyListeners();
  }

  void requestBackup(String backupType) {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final currentBackups = List<String>.from(_activeIncident!.requestedBackups)..add(backupType);

    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-backup',
          timestamp: now,
          title: 'Backup Requested: $backupType',
          description: 'On-scene lead requested auxiliary $backupType support unit',
          stage: 'backup',
          isHighlight: true,
        ),
      );

    _activeIncident = _activeIncident!.copyWith(
      requestedBackups: currentBackups,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    _updateIncidentInList(_activeIncident!);

    _addNotification(
      title: '🚨 Backup Requested: ${_activeIncident!.id}',
      message: '$backupType unit requested at ${_activeIncident!.locationName}',
      priority: NotificationPriority.critical,
      incidentId: _activeIncident!.id,
    );

    notifyListeners();
  }

  void resolveIncident(String resolutionNotes) {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-7',
          timestamp: now,
          title: 'Incident Resolved & Secured',
          description: resolutionNotes.isEmpty
              ? 'Response completed. All affected individuals stabilized.'
              : resolutionNotes,
          stage: 'resolved',
          isHighlight: true,
        ),
      );

    final resolvedIncident = _activeIncident!.copyWith(
      status: IncidentStatus.resolved,
      resolutionSummary: resolutionNotes.isEmpty
          ? 'Emergency neutralized by responder team.'
          : resolutionNotes,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    // Free up responder
    if (resolvedIncident.assignedResponderId != null) {
      _responders = _responders.map((r) {
        if (r.id == resolvedIncident.assignedResponderId) {
          final newWorkload = (r.workload - 1).clamp(0, 10);
          return r.copyWith(
            workload: newWorkload,
            availability: ResponderAvailability.available,
          );
        }
        return r;
      }).toList();
    }

    _activeIncident = null;
    _updateIncidentInList(resolvedIncident);

    _addNotification(
      title: 'Resolved: ${resolvedIncident.id}',
      message: 'Scene closed at ${resolvedIncident.locationName}. Logged to incident archive.',
      priority: NotificationPriority.success,
      incidentId: resolvedIncident.id,
    );

    notifyListeners();
  }

  // Escalation / Reassignment when declined
  void escalateAndReassign(String reason) {
    if (_activeIncident == null) return;

    final now = DateTime.now();
    final prevResponderName = _activeIncident!.assignedResponderName ?? 'Assigned Responder';

    // Find next available responder
    final ranked = rankResponders(_activeIncident!.category);
    final nextResponder = ranked.firstWhere(
      (r) => r.id != _activeIncident!.assignedResponderId && r.availability == ResponderAvailability.available,
      orElse: () => ranked.first,
    );

    final updatedTimeline = List<TimelineEvent>.from(_activeIncident!.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-esc',
          timestamp: now,
          title: 'Assignment Declined & Escalated',
          description: '$prevResponderName declined: "$reason". Auto-escalated to Command Center.',
          stage: 'assigned',
          isHighlight: true,
        ),
      )
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-reassign',
          timestamp: now.add(const Duration(seconds: 1)),
          title: 'Transferred to ${nextResponder.name}',
          description: 'Reassigned to ${nextResponder.callSign} (Match score ${nextResponder.matchScore}%)',
          stage: 'assigned',
        ),
      );

    _activeIncident = _activeIncident!.copyWith(
      assignedResponderId: nextResponder.id,
      assignedResponderName: nextResponder.name,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    _updateIncidentInList(_activeIncident!);

    _addNotification(
      title: 'Escalation Alert: ${_activeIncident!.id}',
      message: 'Declined: $reason. Re-routed to ${nextResponder.name}.',
      priority: NotificationPriority.warning,
      incidentId: _activeIncident!.id,
    );

    notifyListeners();
  }

  void manualOverrideAssign(String incidentId, Responder newResponder) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final inc = _incidents[index];
    final now = DateTime.now();
    final updatedTimeline = List<TimelineEvent>.from(inc.timeline)
      ..add(
        TimelineEvent(
          id: 't-${DateTime.now().millisecondsSinceEpoch}-manual',
          timestamp: now,
          title: 'Command Center Manual Override',
          description: 'Admin manually redirected dispatch to ${newResponder.name} (${newResponder.callSign})',
          stage: 'assigned',
          isHighlight: true,
        ),
      );

    final updated = inc.copyWith(
      assignedResponderId: newResponder.id,
      assignedResponderName: newResponder.name,
      status: IncidentStatus.assigned,
      updatedAt: now,
      timeline: updatedTimeline,
    );

    _incidents[index] = updated;
    if (_activeIncident?.id == incidentId) {
      _activeIncident = updated;
    }

    _addNotification(
      title: 'Manual Dispatch Override',
      message: '${inc.id} routed to ${newResponder.callSign}',
      priority: NotificationPriority.info,
      incidentId: inc.id,
    );

    notifyListeners();
  }

  void setActiveIncident(Incident inc) {
    _activeIncident = inc;
    notifyListeners();
  }

  void _updateIncidentInList(Incident incident) {
    final index = _incidents.indexWhere((i) => i.id == incident.id);
    if (index != -1) {
      _incidents[index] = incident;
    } else {
      _incidents.insert(0, incident);
    }
  }

  void _addNotification({
    required String title,
    required String message,
    required NotificationPriority priority,
    String? incidentId,
  }) {
    final notif = NotificationItem(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      priority: priority,
      incidentId: incidentId,
    );
    _notifications.insert(0, notif);
  }
}
