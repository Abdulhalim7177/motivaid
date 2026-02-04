import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:motivaid/features/auth/widgets/auth_text_field.dart';
import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/features/patients/providers/patient_provider.dart';

class EditPatientScreen extends ConsumerStatefulWidget {
  final String patientId;

  const EditPatientScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends ConsumerState<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _gestationalAgeController = TextEditingController();

  // New Controllers
  final _gravidaController = TextEditingController();
  final _parityController = TextEditingController();
  final _fetalWeightController = TextEditingController();
  final _hemoglobinController = TextEditingController();

  // State variables for new fields
  bool _priorPphHistory = false;
  bool _historyCesareanSection = false;
  bool _hasAntenatalCare = false;
  String? _placentalStatus;
  int _numberOfFetuses = 1;

  // Additional E-MOTIVE Risk Factors
  bool _knownCoagulopathy = false;
  bool _hasFibroids = false;
  bool _hasPolyhydramnios = false;
  bool _laborInduced = false;
  bool _prolongedLabor = false;
  
  RiskLevel _calculatedRiskLevel = RiskLevel.low;
  PatientStatus _selectedStatus = PatientStatus.active;
  
  bool _isLoading = false;
  Patient? _currentPatient;

  final List<String> _placentalOptions = ['Normal', 'Previa', 'Accreta', 'Abruption', 'Unknown'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  Future<void> _loadPatientData() async {
    final patient = await ref.read(patientDetailProvider(widget.patientId).future);
    if (patient != null && mounted) {
      setState(() {
        _currentPatient = patient;
        _fullNameController.text = patient.fullName;
        _ageController.text = patient.age?.toString() ?? '';
        _gestationalAgeController.text = patient.gestationalAgeWeeks?.toString() ?? '';
        
        // Load new fields
        _gravidaController.text = patient.gravida?.toString() ?? '';
        _parityController.text = patient.parity?.toString() ?? '';
        _fetalWeightController.text = patient.estimatedFetalWeight?.toString() ?? '';
        _hemoglobinController.text = patient.baselineHemoglobin?.toString() ?? '';
        
        _priorPphHistory = patient.priorPphHistory;
        _historyCesareanSection = patient.historyCesareanSection;
        _hasAntenatalCare = patient.hasAntenatalCare;
        _placentalStatus = patient.placentalStatus;
        _numberOfFetuses = patient.numberOfFetuses;
        
        // Load additional factors
        _knownCoagulopathy = patient.knownCoagulopathy;
        _hasFibroids = patient.hasFibroids;
        _hasPolyhydramnios = patient.hasPolyhydramnios;
        _laborInduced = patient.laborInduced;
        _prolongedLabor = patient.prolongedLabor;

        _calculatedRiskLevel = patient.riskLevel;
        _selectedStatus = patient.status;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _gestationalAgeController.dispose();
    _gravidaController.dispose();
    _parityController.dispose();
    _fetalWeightController.dispose();
    _hemoglobinController.dispose();
    super.dispose();
  }

  void _calculateRisk() {
    final age = int.tryParse(_ageController.text.trim());
    final parity = int.tryParse(_parityController.text.trim());
    final fetalWeight = double.tryParse(_fetalWeightController.text.trim());
    final hemoglobin = double.tryParse(_hemoglobinController.text.trim());

    final risk = Patient.calculateRisk(
      priorPphHistory: _priorPphHistory,
      placentalStatus: _placentalStatus,
      baselineHemoglobin: hemoglobin,
      age: age,
      parity: parity,
      estimatedFetalWeight: fetalWeight,
      numberOfFetuses: _numberOfFetuses,
      knownCoagulopathy: _knownCoagulopathy,
      hasFibroids: _hasFibroids,
      hasPolyhydramnios: _hasPolyhydramnios,
      laborInduced: _laborInduced,
      prolongedLabor: _prolongedLabor,
    );

    setState(() {
      _calculatedRiskLevel = risk;
    });
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_currentPatient == null) {
        throw Exception('Patient not found');
      }

      final updatedPatient = _currentPatient!.copyWith(
        fullName: _fullNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gestationalAgeWeeks: int.tryParse(_gestationalAgeController.text.trim()),
        riskLevel: _calculatedRiskLevel,
        status: _selectedStatus,
        updatedAt: DateTime.now(),
        // Update new fields
        gravida: int.tryParse(_gravidaController.text.trim()),
        parity: int.tryParse(_parityController.text.trim()),
        priorPphHistory: _priorPphHistory,
        historyCesareanSection: _historyCesareanSection,
        hasAntenatalCare: _hasAntenatalCare,
        placentalStatus: _placentalStatus,
        estimatedFetalWeight: double.tryParse(_fetalWeightController.text.trim()),
        numberOfFetuses: _numberOfFetuses,
        baselineHemoglobin: double.tryParse(_hemoglobinController.text.trim()),
        knownCoagulopathy: _knownCoagulopathy,
        hasFibroids: _hasFibroids,
        hasPolyhydramnios: _hasPolyhydramnios,
        laborInduced: _laborInduced,
        prolongedLabor: _prolongedLabor,
      );

      final notifier = ref.read(patientNotifierProvider);
      await notifier.updatePatient(updatedPatient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        ref.invalidate(patientDetailProvider(widget.patientId));
        ref.invalidate(allPatientsProvider);
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update patient: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildRiskSwitch(String title, String subtitle, bool value, Function(bool) onChanged, {bool isCritical = false}) {
    final color = value 
        ? (isCritical ? Colors.red : Colors.orange) 
        : Colors.green;
        
    final icon = value 
        ? (isCritical ? Icons.warning_amber_rounded : Icons.info_outline)
        : Icons.check_circle_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        value: value,
        onChanged: (val) {
          onChanged(val);
          _calculateRisk();
        },
        activeTrackColor: value ? (isCritical ? Colors.red : Colors.orange) : Colors.green,
        activeThumbColor: Colors.white, // thumb color when active
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.green.withValues(alpha: 0.5),
        secondary: Icon(icon, color: color),
      ),
    );
  }

  Widget _buildColoredField({required Widget child, required bool isRisk, bool isCritical = false}) {
    final color = isRisk 
        ? (isCritical ? Colors.red : Colors.orange) 
        : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPatient == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Helper logic for field states
    int age = int.tryParse(_ageController.text) ?? 0;
    bool isAgeRisk = age > 0 && (age < 18 || age > 35);
    bool isParityRisk = (int.tryParse(_parityController.text) ?? 0) > 4;
    bool isFetalWeightRisk = (double.tryParse(_fetalWeightController.text) ?? 0) > 4.0;
    double? hb = double.tryParse(_hemoglobinController.text);
    bool isHbRisk = hb != null && hb < 11.0;
    bool isPlacentaRisk = _placentalStatus != null && _placentalStatus != 'Normal' && _placentalStatus != 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          onChanged: () {
            _calculateRisk();
            setState(() {});
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Basic Information
              const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              _buildColoredField(
                isRisk: false,
                child: AuthTextField(
                  controller: _fullNameController,
                  labelText: 'Full Name',
                  hintText: 'Enter patient full name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildColoredField(
                      isRisk: isAgeRisk,
                      child: AuthTextField(
                        controller: _ageController,
                        labelText: 'Age',
                        hintText: 'Years',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.calendar_today_outlined,
                        validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildColoredField(
                      isRisk: false,
                      child: AuthTextField(
                        controller: _gestationalAgeController,
                        labelText: 'Gestational Age',
                        hintText: 'Weeks',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.child_care_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Obstetric History
              const Text('Obstetric History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildColoredField(
                      isRisk: false,
                      child: AuthTextField(
                        controller: _gravidaController,
                        labelText: 'Gravida',
                        hintText: 'Total',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildColoredField(
                      isRisk: isParityRisk,
                      child: AuthTextField(
                        controller: _parityController,
                        labelText: 'Parity',
                        hintText: 'Live births',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildRiskSwitch(
                'Prior PPH History',
                'History of previous postpartum hemorrhage',
                _priorPphHistory,
                (val) => setState(() => _priorPphHistory = val),
                isCritical: true,
              ),
              _buildRiskSwitch(
                'History of C-Section',
                'Previous cesarean section delivery',
                _historyCesareanSection,
                (val) => setState(() => _historyCesareanSection = val),
              ),
              _buildRiskSwitch(
                'Known Coagulopathy',
                'Bleeding disorders (e.g., von Willebrand)',
                _knownCoagulopathy,
                (val) => setState(() => _knownCoagulopathy = val),
                isCritical: true,
              ),

              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Has Antenatal Care History'),
                value: _hasAntenatalCare,
                onChanged: (val) => setState(() => _hasAntenatalCare = val),
                secondary: const Icon(Icons.medical_services_outlined),
              ),
              const SizedBox(height: 24),

              // 3. Current Pregnancy Risk Factors
              const Text('Current Pregnancy Factors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              _buildColoredField(
                isRisk: isPlacentaRisk,
                isCritical: true,
                child: DropdownButtonFormField<String>(
                  initialValue: _placentalStatus,
                  decoration: const InputDecoration(
                    labelText: 'Placental Status',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: Icon(Icons.airline_seat_flat_angled_outlined),
                  ),
                  items: _placentalOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _placentalStatus = val);
                    _calculateRisk();
                  },
                ),
              ),

              const SizedBox(height: 16),

              _buildRiskSwitch(
                'Polyhydramnios',
                'Excessive amniotic fluid (overdistension)',
                _hasPolyhydramnios,
                (val) => setState(() => _hasPolyhydramnios = val),
              ),
              _buildRiskSwitch(
                'Uterine Fibroids',
                'Presence of large fibroids',
                _hasFibroids,
                (val) => setState(() => _hasFibroids = val),
              ),
              _buildRiskSwitch(
                'Labor Induced',
                'Oxytocin used for induction',
                _laborInduced,
                (val) => setState(() => _laborInduced = val),
              ),
              _buildRiskSwitch(
                'Prolonged Labor',
                'Active labor > 12 hours',
                _prolongedLabor,
                (val) => setState(() => _prolongedLabor = val),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildColoredField(
                      isRisk: isFetalWeightRisk,
                      child: AuthTextField(
                        controller: _fetalWeightController,
                        labelText: 'Est. Fetal Weight',
                        hintText: 'kg',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildColoredField(
                      isRisk: isHbRisk,
                      isCritical: isHbRisk && hb < 7.0,
                      child: AuthTextField(
                        controller: _hemoglobinController,
                        labelText: 'Baseline Hb',
                        hintText: 'g/dL',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Number of Fetuses'),
              Row(
                children: [
                  Expanded(
                    child: _buildColoredField(
                      isRisk: false,
                      child: RadioListTile<int>(
                        title: const Text('Singleton'),
                        value: 1,
                        groupValue: _numberOfFetuses,
                        onChanged: (val) {
                          setState(() => _numberOfFetuses = val!);
                          _calculateRisk();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildColoredField(
                      isRisk: true,
                      child: RadioListTile<int>(
                        title: const Text('Multiple'),
                        value: 2,
                        groupValue: _numberOfFetuses,
                        onChanged: (val) {
                          setState(() => _numberOfFetuses = val!);
                          _calculateRisk();
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              
              // 4. Risk Assessment (Display Only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getRiskColor(_calculatedRiskLevel).withValues(alpha: 0.1),
                  border: Border.all(color: _getRiskColor(_calculatedRiskLevel)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Assessed Risk Level', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    RiskBadge(risk: _calculatedRiskLevel),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PatientStatus>(
                segments: const [
                  ButtonSegment(
                    value: PatientStatus.active,
                    label: Text('Active'),
                  ),
                  ButtonSegment(
                    value: PatientStatus.discharged,
                    label: Text('Discharged'),
                  ),
                  ButtonSegment(
                    value: PatientStatus.transferred,
                    label: Text('Transferred'),
                  ),
                ],
                selected: {_selectedStatus},
                onSelectionChanged: (Set<PatientStatus> newSelection) {
                  setState(() {
                    _selectedStatus = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _savePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high: return Colors.red;
      case RiskLevel.medium: return Colors.orange;
      case RiskLevel.low: return Colors.green;
    }
  }
}
