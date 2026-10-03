import 'package:flutter/material.dart';
import '../../../models/incident.dart';
import '../../../state/rescue_scope.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../severity_analysis_screen.dart';

class ReportFlowScreen extends StatefulWidget {
  const ReportFlowScreen({super.key});

  @override
  State<ReportFlowScreen> createState() => _ReportFlowScreenState();
}

class _ReportFlowScreenState extends State<ReportFlowScreen> {
  int _currentStep = 0;

  // Form State
  IncidentCategory _selectedCategory = IncidentCategory.medical;
  int _peopleAffected = 1;
  final TextEditingController _descController = TextEditingController(
    text: 'Student collapsed near lab entrance. Unconscious and breathing heavily.',
  );
  bool _hasPhotoAttached = true;

  String _locationName = 'CSE Block, Lab 204';
  String _landmark = 'Opposite AI Research Lab, 2nd Floor';

  final List<String> _quickTags = [
    'Unconscious',
    'Severe Bleeding',
    'Chest Pain',
    'Fainted',
    'Trapped',
    'Active Smoke',
  ];

  final List<Map<String, String>> _campusLocations = [
    {'name': 'CSE Block, Lab 204', 'landmark': 'Opposite AI Research Lab, 2nd Floor'},
    {'name': 'Central Library', 'landmark': 'East Wing Silent Reading Room'},
    {'name': 'Hostel Complex B', 'landmark': 'Near Ground Floor Cafeteria'},
    {'name': 'Sports Arena', 'landmark': 'Basketball Indoor Court'},
    {'name': 'Science Complex', 'landmark': 'Chemistry Lab Wing 3'},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitReport();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _submitReport() {
    final state = RescueScope.of(context);
    final createdIncident = state.createIncident(
      category: _selectedCategory,
      peopleAffected: _peopleAffected,
      description: _descController.text.trim(),
      locationName: _locationName,
      landmark: _landmark,
      photoAsset: _hasPhotoAttached ? 'demo_incident_photo.jpg' : null,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SeverityAnalysisScreen(incident: createdIncident),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Report Emergency'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.surface,
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index == _currentStep;
                  final isDone = index < _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isDone || isActive
                            ? AppTheme.emergencyRed
                            : AppTheme.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Step Title Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.surfaceLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      color: AppTheme.pulseCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'STEP ${_currentStep + 1} OF 4',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Body Content per Step
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _buildStepContent(),
              ),
            ),

            // Bottom Navigation Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: PrimaryButton(
                        text: 'BACK',
                        isOutline: true,
                        onPressed: _prevStep,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: _currentStep == 3 ? 'CONFIRM & REPORT' : 'CONTINUE',
                      icon: _currentStep == 3
                          ? Icons.emergency_rounded
                          : Icons.arrow_forward_rounded,
                      isDanger: _currentStep == 3,
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'SELECT INCIDENT TYPE';
      case 1:
        return 'SITUATION DETAILS';
      case 2:
        return 'VERIFY CAMPUS LOCATION';
      case 3:
        return 'REVIEW & SUBMIT';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Category();
      case 1:
        return _buildStep2Details();
      case 2:
        return _buildStep3Location();
      case 3:
        return _buildStep4Review();
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Emergency Category
  Widget _buildStep1Category() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is happening?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose the primary category for appropriate responder routing.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),
        ...IncidentCategory.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppTheme.emergencyRed : AppTheme.surfaceBorder,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.emergencyRed.withValues(alpha: 0.2)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        cat.icon,
                        color: isSelected ? AppTheme.emergencyRed : AppTheme.pulseCyan,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
                      color: isSelected ? AppTheme.emergencyRed : AppTheme.textMuted,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 2: Situation Details
  Widget _buildStep2Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Situation Details',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Help responders prepare the right equipment before arrival.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // People affected counter
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people_alt_rounded, color: AppTheme.pulseCyan, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PEOPLE AFFECTED',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Estimated casualty / victim count',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textSecondary),
                    onPressed: () {
                      if (_peopleAffected > 1) {
                        setState(() => _peopleAffected--);
                      }
                    },
                  ),
                  Text(
                    '$_peopleAffected',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.pulseCyan),
                    onPressed: () {
                      setState(() => _peopleAffected++);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Quick keyword chips
        const Text(
          'QUICK TAGS (TAP TO ADD)',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickTags.map((tag) {
            final isAdded = _descController.text.contains(tag);
            return InkWell(
              onTap: () {
                setState(() {
                  if (!isAdded) {
                    _descController.text = _descController.text.isEmpty
                        ? tag
                        : '${_descController.text}, $tag';
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isAdded
                      ? AppTheme.pulseCyan.withValues(alpha: 0.15)
                      : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAdded ? AppTheme.pulseCyan : AppTheme.surfaceBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdded ? Icons.check : Icons.add,
                      size: 12,
                      color: isAdded ? AppTheme.pulseCyan : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: TextStyle(
                        color: isAdded ? AppTheme.pulseCyan : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Description field
        const Text(
          'SITUATION DESCRIPTION',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 3,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Describe injuries, symptoms, hazards, or immediate dangers...',
          ),
        ),
        const SizedBox(height: 18),

        // Photo attachment simulation
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Icon(
                  _hasPhotoAttached ? Icons.camera_alt_rounded : Icons.add_a_photo_outlined,
                  color: _hasPhotoAttached ? AppTheme.pulseCyan : AppTheme.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasPhotoAttached ? 'Photo Evidence Attached' : 'Attach Photo (Optional)',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _hasPhotoAttached
                          ? 'scene_evidence_cam01.jpg (Auto-analyzed)'
                          : 'Visual photo assists triage crew',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _hasPhotoAttached,
                activeThumbColor: AppTheme.pulseCyan,
                onChanged: (val) => setState(() => _hasPhotoAttached = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: Location
  Widget _buildStep3Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Location',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Precise campus vector ensures responders arrive within seconds.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Detected GPS Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.emergencyRed.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.emergencyRed.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.emergencyRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.my_location_rounded, color: AppTheme.emergencyRed, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GPS LOCATION LOCKED (± 1.2m)',
                    style: TextStyle(
                      color: AppTheme.emergencyRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _locationName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _landmark,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Quick campus zones
        const Text(
          'SELECT OR OVERRIDE CAMPUS ZONE',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        ..._campusLocations.map((loc) {
          final isSelected = _locationName == loc['name'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _locationName = loc['name']!;
                  _landmark = loc['landmark']!;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppTheme.pulseCyan : AppTheme.surfaceBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: isSelected ? AppTheme.pulseCyan : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc['name']!,
                            style: TextStyle(
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            loc['landmark']!,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 4: Review
  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Emergency Notice',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Please verify the details below before sounding the dispatch alarm.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.emergencyRed.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.emergencyRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_selectedCategory.icon, color: AppTheme.emergencyRed, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCategory.label.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Estimated $_peopleAffected person(s) affected',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              _buildReviewRow('LOCATION', _locationName),
              const SizedBox(height: 8),
              _buildReviewRow('LANDMARK', _landmark),
              const SizedBox(height: 8),
              _buildReviewRow('DETAILS', _descController.text),
              const SizedBox(height: 8),
              _buildReviewRow('PHOTO', _hasPhotoAttached ? 'Attached (Camera Scene)' : 'None'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppTheme.warningAmber, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Auto-dispatch algorithm will instantly match the fastest qualified team upon submission.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
