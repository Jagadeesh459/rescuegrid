import 'package:flutter/material.dart';
import 'timeline_event.dart';

enum IncidentCategory {
  medical('Medical', Icons.medical_services_rounded, 'Cardiac, fainting, severe injury, allergy'),
  fire('Fire Alert', Icons.local_fire_department_rounded, 'Smoke, active flame, chemical hazard'),
  security('Security', Icons.shield_rounded, 'Intruder, physical threat, assault, panic'),
  accident('Accident', Icons.car_crash_rounded, 'Vehicle collision, heavy fall, crush injury'),
  hazard('Hazard', Icons.warning_amber_rounded, 'Gas leak, biohazard, fallen high-voltage wire'),
  infrastructure('Infrastructure', Icons.handyman_rounded, 'Elevator trapped, structural ceiling collapse'),
  other('Other Alert', Icons.emergency_rounded, 'General urgent safety concern');

  final String label;
  final IconData icon;
  final String description;
  const IncidentCategory(this.label, this.icon, this.description);
}

enum IncidentSeverity {
  critical('CRITICAL', 'Immediate life threat. Full dispatch.', Color(0xFFEF4444)),
  high('HIGH', 'Urgent response required. Rapid team.', Color(0xFFF97316)),
  medium('MEDIUM', 'Priority incident. Standard unit.', Color(0xFFF59E0B)),
  low('LOW', 'Routine support / verification.', Color(0xFF3B82F6));

  final String label;
  final String subtitle;
  final Color color;
  const IncidentSeverity(this.label, this.subtitle, this.color);
}

enum IncidentStatus {
  reported('REPORTED', 1),
  assessed('ASSESSED', 2),
  assigned('ASSIGNED', 3),
  accepted('ACCEPTED', 4),
  enRoute('EN ROUTE', 5),
  arrived('ARRIVED', 6),
  resolved('RESOLVED', 7);

  final String label;
  final int step;
  const IncidentStatus(this.label, this.step);
}

class Incident {
  final String id;
  final IncidentCategory category;
  final IncidentSeverity severity;
  final String description;
  final int peopleAffected;
  final String locationName;
  final String landmark;
  final double latitude;
  final double longitude;
  final String? photoAsset;
  final IncidentStatus status;
  final String? assignedResponderId;
  final String? assignedResponderName;
  final String reporterName;
  final String reporterId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TimelineEvent> timeline;
  final List<String> requestedBackups;
  final String? resolutionSummary;

  const Incident({
    required this.id,
    required this.category,
    required this.severity,
    required this.description,
    required this.peopleAffected,
    required this.locationName,
    required this.landmark,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.photoAsset,
    required this.status,
    this.assignedResponderId,
    this.assignedResponderName,
    required this.reporterName,
    required this.reporterId,
    required this.createdAt,
    required this.updatedAt,
    required this.timeline,
    this.requestedBackups = const [],
    this.resolutionSummary,
  });

  Incident copyWith({
    String? id,
    IncidentCategory? category,
    IncidentSeverity? severity,
    String? description,
    int? peopleAffected,
    String? locationName,
    String? landmark,
    double? latitude,
    double? longitude,
    String? photoAsset,
    IncidentStatus? status,
    String? assignedResponderId,
    String? assignedResponderName,
    String? reporterName,
    String? reporterId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TimelineEvent>? timeline,
    List<String>? requestedBackups,
    String? resolutionSummary,
  }) {
    return Incident(
      id: id ?? this.id,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      peopleAffected: peopleAffected ?? this.peopleAffected,
      locationName: locationName ?? this.locationName,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoAsset: photoAsset ?? this.photoAsset,
      status: status ?? this.status,
      assignedResponderId: assignedResponderId ?? this.assignedResponderId,
      assignedResponderName: assignedResponderName ?? this.assignedResponderName,
      reporterName: reporterName ?? this.reporterName,
      reporterId: reporterId ?? this.reporterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeline: timeline ?? this.timeline,
      requestedBackups: requestedBackups ?? this.requestedBackups,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
    );
  }
}

