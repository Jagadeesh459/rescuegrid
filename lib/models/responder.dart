enum ResponderType {
  medical('Medical Team', 'First Aid, Triage, CPR, Trauma Care'),
  security('Campus Security', 'De-escalation, Crowd Control, Patrol'),
  fire('Fire Response', 'Extinguisher, Hazard Containment, Evacuation'),
  rapid('Rapid Response', 'General Emergency, Quick Escort, Perimeter');

  final String label;
  final String skillsSummary;
  const ResponderType(this.label, this.skillsSummary);
}

enum ResponderAvailability {
  available('Available'),
  busy('Busy / Dispatched'),
  offline('Off Duty');

  final String label;
  const ResponderAvailability(this.label);
}

class Responder {
  final String id;
  final String name;
  final String callSign;
  final ResponderType type;
  final List<String> skills;
  final ResponderAvailability availability;
  final int workload; // Current active assignments
  final double distanceKm;
  final int etaMinutes;
  final int skillMatchPercent;
  final int matchScore; // Calculated 0-100
  final String locationName;
  final String phone;

  const Responder({
    required this.id,
    required this.name,
    required this.callSign,
    required this.type,
    required this.skills,
    required this.availability,
    required this.workload,
    required this.distanceKm,
    required this.etaMinutes,
    required this.skillMatchPercent,
    required this.matchScore,
    required this.locationName,
    required this.phone,
  });

  Responder copyWith({
    String? id,
    String? name,
    String? callSign,
    ResponderType? type,
    List<String>? skills,
    ResponderAvailability? availability,
    int? workload,
    double? distanceKm,
    int? etaMinutes,
    int? skillMatchPercent,
    int? matchScore,
    String? locationName,
    String? phone,
  }) {
    return Responder(
      id: id ?? this.id,
      name: name ?? this.name,
      callSign: callSign ?? this.callSign,
      type: type ?? this.type,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      workload: workload ?? this.workload,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      skillMatchPercent: skillMatchPercent ?? this.skillMatchPercent,
      matchScore: matchScore ?? this.matchScore,
      locationName: locationName ?? this.locationName,
      phone: phone ?? this.phone,
    );
  }
}

