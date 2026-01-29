import 'package:motivaid/core/widgets/risk_badge.dart';

extension RiskLevelExtension on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.high:
        return 'High';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.low:
        return 'Low';
    }
  }

  static RiskLevel fromString(String value) {
    return RiskLevel.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => RiskLevel.low,
    );
  }
}

enum PatientStatus {
  active,
  discharged,
  transferred;
  
  String get label {
    switch (this) {
      case PatientStatus.active:
        return 'Active';
      case PatientStatus.discharged:
        return 'Discharged';
      case PatientStatus.transferred:
        return 'Transferred';
    }
  }

  static PatientStatus fromString(String value) {
    return PatientStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => PatientStatus.active,
    );
  }
}


class Patient {
  final String id;
  final String fullName;
  final int? age;
  final int? gestationalAgeWeeks;
  final RiskLevel riskLevel;
  final PatientStatus status;
  final String midwifeId;
  final String? facilityId;
  final DateTime? lastAssessmentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.fullName,
    this.age,
    this.gestationalAgeWeeks,
    required this.riskLevel,
    required this.status,
    required this.midwifeId,
    this.facilityId,
    this.lastAssessmentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      age: json['age'] as int?,
      gestationalAgeWeeks: json['gestational_age_weeks'] as int?,
      riskLevel: RiskLevelExtension.fromString(json['risk_level'] as String? ?? 'Low'),
      status: PatientStatus.fromString(json['status'] as String? ?? 'Active'),
      midwifeId: json['midwife_id'] as String,
      facilityId: json['facility_id'] as String?,
      lastAssessmentDate: json['last_assessment_date'] != null
          ? DateTime.parse(json['last_assessment_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'age': age,
      'gestational_age_weeks': gestationalAgeWeeks,
      'risk_level': riskLevel.label,
      'status': status.label,
      'midwife_id': midwifeId,
      'facility_id': facilityId,
      'last_assessment_date': lastAssessmentDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Patient copyWith({
    String? id,
    String? fullName,
    int? age,
    int? gestationalAgeWeeks,
    RiskLevel? riskLevel,
    PatientStatus? status,
    String? midwifeId,
    String? facilityId,
    DateTime? lastAssessmentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gestationalAgeWeeks: gestationalAgeWeeks ?? this.gestationalAgeWeeks,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      midwifeId: midwifeId ?? this.midwifeId,
      facilityId: facilityId ?? this.facilityId,
      lastAssessmentDate: lastAssessmentDate ?? this.lastAssessmentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
