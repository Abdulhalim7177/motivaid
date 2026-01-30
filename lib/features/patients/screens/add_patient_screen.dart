import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motivaid/core/auth/providers/auth_provider.dart';
import 'package:motivaid/core/widgets/risk_badge.dart';
import 'package:motivaid/features/auth/widgets/auth_text_field.dart';
import 'package:motivaid/features/patients/models/patient.dart';
import 'package:motivaid/features/patients/providers/patient_provider.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _gestationalAgeController = TextEditingController();
  
  RiskLevel _selectedRiskLevel = RiskLevel.low;
  PatientStatus _selectedStatus = PatientStatus.active;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _gestationalAgeController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final currentUser = authNotifier.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final newPatient = Patient(
        id: '',
        fullName: _fullNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gestationalAgeWeeks: int.tryParse(_gestationalAgeController.text.trim()),
        riskLevel: _selectedRiskLevel,
        status: _selectedStatus,
        midwifeId: currentUser.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final notifier = ref.read(patientNotifierProvider);
      await notifier.createPatient(newPatient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        ref.invalidate(allPatientsProvider);
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          context.pop(true);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add patient: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _fullNameController,
                labelText: 'Full Name',
                hintText: 'Enter patient full name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AuthTextField(
                controller: _ageController,
                labelText: 'Age',
                hintText: 'Enter patient age',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_today_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter age';
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null || age < 10 || age > 60) {
                    return 'Please enter a valid age (10-60)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AuthTextField(
                controller: _gestationalAgeController,
                labelText: 'Gestational Age (weeks)',
                hintText: 'Enter gestational age',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.child_care_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter gestational age';
                  }
                  final ga = int.tryParse(value.trim());
                  if (ga == null || ga < 0 || ga > 42) {
                    return 'Please enter a valid gestational age (0-42)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Risk Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<RiskLevel>(
                segments: const [
                  ButtonSegment(
                    value: RiskLevel.low,
                    label: Text('Low'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                  ButtonSegment(
                    value: RiskLevel.medium,
                    label: Text('Medium'),
                    icon: Icon(Icons.warning_outlined),
                  ),
                  ButtonSegment(
                    value: RiskLevel.high,
                    label: Text('High'),
                    icon: Icon(Icons.error_outline),
                  ),
                ],
                selected: {_selectedRiskLevel},
                onSelectionChanged: (Set<RiskLevel> newSelection) {
                  setState(() {
                    _selectedRiskLevel = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
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
                        'Add Patient',
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
}
