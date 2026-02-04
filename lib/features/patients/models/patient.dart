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

  // Detailed risk factors
  final int? gravida;
  final int? parity;
  final bool priorPphHistory;
  final bool historyCesareanSection;
  final bool hasAntenatalCare;
  final String? placentalStatus; // Normal, Previa, Accreta, Abruption, Unknown
  final double? estimatedFetalWeight; // kg
  final int numberOfFetuses; // 1 = Singleton, >1 = Multiple
  final double? baselineHemoglobin; // g/dL

  // Additional E-MOTIVE Risk Factors
  final bool knownCoagulopathy;
  final bool hasFibroids;
  final bool hasPolyhydramnios;
  final bool laborInduced;
  final bool prolongedLabor; // >12 hours

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
    this.gravida,
    this.parity,
    this.priorPphHistory = false,
    this.historyCesareanSection = false,
    this.hasAntenatalCare = false,
    this.placentalStatus,
    this.estimatedFetalWeight,
    this.numberOfFetuses = 1,
    this.baselineHemoglobin,
    this.knownCoagulopathy = false,
    this.hasFibroids = false,
    this.hasPolyhydramnios = false,
    this.laborInduced = false,
    this.prolongedLabor = false,
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
      gravida: json['gravida'] as int?,
      parity: json['parity'] as int?,
      priorPphHistory: json['prior_pph_history'] as bool? ?? false,
      historyCesareanSection: json['history_cesarean_section'] as bool? ?? false,
      hasAntenatalCare: json['has_antenatal_care'] as bool? ?? false,
      placentalStatus: json['placental_status'] as String?,
      estimatedFetalWeight: (json['estimated_fetal_weight'] as num?)?.toDouble(),
      numberOfFetuses: json['number_of_fetuses'] as int? ?? 1,
      baselineHemoglobin: (json['baseline_hemoglobin'] as num?)?.toDouble(),
      knownCoagulopathy: json['known_coagulopathy'] as bool? ?? false,
      hasFibroids: json['has_fibroids'] as bool? ?? false,
      hasPolyhydramnios: json['has_polyhydramnios'] as bool? ?? false,
      laborInduced: json['labor_induced'] as bool? ?? false,
      prolongedLabor: json['prolonged_labor'] as bool? ?? false,
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
      'gravida': gravida,
      'parity': parity,
      'prior_pph_history': priorPphHistory,
      'history_cesarean_section': historyCesareanSection,
      'has_antenatal_care': hasAntenatalCare,
      'placental_status': placentalStatus,
      'estimated_fetal_weight': estimatedFetalWeight,
      'number_of_fetuses': numberOfFetuses,
      'baseline_hemoglobin': baselineHemoglobin,
      'known_coagulopathy': knownCoagulopathy,
      'has_fibroids': hasFibroids,
      'has_polyhydramnios': hasPolyhydramnios,
      'labor_induced': laborInduced,
      'prolonged_labor': prolongedLabor,
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
    int? gravida,
    int? parity,
    bool? priorPphHistory,
    bool? historyCesareanSection,
    bool? hasAntenatalCare,
    String? placentalStatus,
    double? estimatedFetalWeight,
    int? numberOfFetuses,
    double? baselineHemoglobin,
    bool? knownCoagulopathy,
    bool? hasFibroids,
    bool? hasPolyhydramnios,
    bool? laborInduced,
    bool? prolongedLabor,
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
      gravida: gravida ?? this.gravida,
      parity: parity ?? this.parity,
      priorPphHistory: priorPphHistory ?? this.priorPphHistory,
      historyCesareanSection: historyCesareanSection ?? this.historyCesareanSection,
      hasAntenatalCare: hasAntenatalCare ?? this.hasAntenatalCare,
      placentalStatus: placentalStatus ?? this.placentalStatus,
      estimatedFetalWeight: estimatedFetalWeight ?? this.estimatedFetalWeight,
      numberOfFetuses: numberOfFetuses ?? this.numberOfFetuses,
      baselineHemoglobin: baselineHemoglobin ?? this.baselineHemoglobin,
      knownCoagulopathy: knownCoagulopathy ?? this.knownCoagulopathy,
      hasFibroids: hasFibroids ?? this.hasFibroids,
      hasPolyhydramnios: hasPolyhydramnios ?? this.hasPolyhydramnios,
      laborInduced: laborInduced ?? this.laborInduced,
      prolongedLabor: prolongedLabor ?? this.prolongedLabor,
    );
  }

  /// Calculates the risk level based on clinical guidelines.
  /// 
  /// Logic / Alert Trigger:
  /// - Prior PPH History: CRITICAL ALERT -> High Risk
  /// - Placental Status (Previa, Accreta, Abruption) -> High Risk
  /// - Baseline Hemoglobin < 11.0 g/dL -> Medium/High Risk (Anemia)
  /// - Maternal Age > 35 -> Increased Risk
  /// - Parity > 4 (Grand Multiparity) -> Increased Risk
  /// - Estimated Fetal Weight > 4.0kg (Macrosomia) -> Increased Risk
  /// - Multiple Gestation > 1 -> Increased Risk
  static RiskLevel calculateRisk({
    required bool priorPphHistory,
    required String? placentalStatus,
    required double? baselineHemoglobin,
    required int? age,
    required int? parity,
    required double? estimatedFetalWeight,
    required int numberOfFetuses,
    required bool knownCoagulopathy,
    required bool hasFibroids,
    required bool hasPolyhydramnios,
    required bool laborInduced,
    required bool prolongedLabor,
  }) {
    // 1. Critical High Risk Factors (Immediate High)
    if (priorPphHistory) return RiskLevel.high;
    if (knownCoagulopathy) return RiskLevel.high;
    
    final criticalPlacentalConditions = ['Previa', 'Accreta', 'Abruption'];
    if (placentalStatus != null && 
        criticalPlacentalConditions.any((c) => placentalStatus.toLowerCase().contains(c.toLowerCase()))) {
      return RiskLevel.high;
    }

    // 2. Count accumulation of moderate risk factors
    int riskScore = 0;

    // Anemia (Hb < 11.0)
    if (baselineHemoglobin != null && baselineHemoglobin < 11.0) {
      // Severe anemia (< 7.0) is definitely high risk, but let's weigh < 11 as significant
      if (baselineHemoglobin < 7.0) return RiskLevel.high;
      riskScore += 2; 
    }

    // Advanced Maternal Age (> 35)
    if (age != null && age > 35) riskScore += 1;

    // Grand Multiparity (> 4)
    if (parity != null && parity > 4) riskScore += 1;

    // Macrosomia (> 4.0 kg)
    if (estimatedFetalWeight != null && estimatedFetalWeight > 4.0) riskScore += 1;

    // Multiple Gestation (> 1)
    if (numberOfFetuses > 1) riskScore += 2; // Twins/Triplets are significant risk
    
    // Polyhydramnios (overdistension)
    if (hasPolyhydramnios) riskScore += 2;

    // Fibroids (contractility issue)
    if (hasFibroids) riskScore += 1;
    
    // Induced Labor (uterine fatigue/atony risk)
    if (laborInduced) riskScore += 1;

    // Prolonged Labor (uterine fatigue)
    if (prolongedLabor) riskScore += 1;

    // 3. Determine level based on score
    if (riskScore >= 3) {
      return RiskLevel.high;
    } else if (riskScore >= 1) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.low;
    }
  }
}
