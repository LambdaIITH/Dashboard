import 'package:dashbaord/constants/hostel_complaint_data.dart';
import 'package:dashbaord/models/hostel_complaint_model.dart';
import 'package:dashbaord/models/user_complaint_model.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:dashbaord/widgets/hostel_complaints/complaint_card.dart';
import 'package:dashbaord/widgets/hostel_complaints/complaint_option_card.dart';
import 'package:dashbaord/widgets/hostel_complaints/empty_complaints_view.dart';
import 'package:dashbaord/widgets/hostel_complaints/navigation_buttons.dart';
import 'package:dashbaord/widgets/hostel_complaints/photo_picker_section.dart';
import 'package:dashbaord/widgets/hostel_complaints/progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HostelComplaintsScreen extends StatefulWidget {
  const HostelComplaintsScreen({super.key});

  @override
  State<HostelComplaintsScreen> createState() => _HostelComplaintsScreenState();
}

class _HostelComplaintsScreenState extends State<HostelComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;
  String? _complaintType;
  String? _subCategory;
  String? _issueType;
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _files = [];
  List<UserComplaintModel> _pastComplaints = [];
  bool _isLoadingComplaints = false;

  bool _needsSubCategory() => HostelComplaintData.hasSubCategory(_complaintType);

  bool _needsIssueType() => HostelComplaintData.hasIssueType(_complaintType, _subCategory);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _pastComplaints.isEmpty && !_isLoadingComplaints) {
        _loadPastComplaints();
      }
    });
  }

  Future<void> _loadPastComplaints() async {
    setState(() => _isLoadingComplaints = true);
    try {
      final complaints = await ApiServices().getUserHostelComplaints(context);
      setState(() {
        _pastComplaints = complaints;
        _isLoadingComplaints = false;
      });
    } catch (e) {
      setState(() => _isLoadingComplaints = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load complaints: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    if (_files.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 photos allowed'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Photo Source',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xffFE724C)),
                title: Text(
                  'Camera',
                  style: GoogleFonts.inter(color: textColor),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    setState(() {
                      _files.add(photo.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xffFE724C)),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.inter(color: textColor),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    setState(() {
                      _files.add(photo.path);
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      if (_currentStep == 0 && _complaintType != null) {
        if (_needsSubCategory()) {
          _currentStep = 1;
        } else {
          _currentStep = 3;
        }
      } else if (_currentStep == 1 && _subCategory != null) {
        if (_needsIssueType()) {
          _currentStep = 2;
        } else {
          _currentStep = 3;
        }
      } else if (_currentStep == 2 && _issueType != null) {
        _currentStep = 3;
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep == 3) {
        if (_needsIssueType()) {
          _currentStep = 2;
        } else if (_needsSubCategory()) {
          _currentStep = 1;
        } else {
          _currentStep = 0;
        }
      } else if (_currentStep == 2) {
        _currentStep = 1;
      } else if (_currentStep == 1) {
        _currentStep = 0;
      }
    });
  }

  void _submitComplaint() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a description'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check for phone number
    final userDetails = await ApiServices().getUserDetails(context);

    if (userDetails?.phone == null || userDetails?.phone == '') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Attention!',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please update your phone number in the profile section before submitting a complaint.',
            style: GoogleFonts.inter(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Go to Profile'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/me', extra: {'onThemeChanged': (int v) {}});
              },
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xffFE724C),
        ),
      ),
    );

    try {
      final complaintData = <String, dynamic>{};

      if (_subCategory != null) {
        final complaintTypeLower = _complaintType!.toLowerCase().replaceAll(' ', '_');

        if (_complaintType == 'Furniture') {
          complaintData['furniture_type'] = _subCategory;
        } else {
          complaintData['${complaintTypeLower}_location'] = _subCategory;
        }
      }

      if (_issueType != null) {
        final complaintTypeLower = _complaintType!.toLowerCase().replaceAll(' ', '_');
        final subCategoryLower =
            _subCategory!.toLowerCase().replaceAll(' ', '_').replaceAll('and', 'and');
        complaintData['${complaintTypeLower}_${subCategoryLower}_issue'] = _issueType;
      }

      final complaint = HostelComplaintModel(
        complaintType: _complaintType!,
        description: _descriptionController.text,
        photosPaths: _files,
        complaintData: complaintData,
      );

      final success = await ApiServices().postHostelComplaint(complaint);

      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Complaint submitted successfully'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
            ),
          );

          setState(() {
            _currentStep = 0;
            _complaintType = null;
            _subCategory = null;
            _issueType = null;
            _issueType = null;
            _descriptionController.clear();
            _files.clear();
          });

          _loadPastComplaints();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit complaint. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Hostel Complaints'),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xffFE724C),
              unselectedLabelColor: textColor.withOpacity(0.6),
              indicatorColor: const Color(0xffFE724C),
              labelStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'New Complaint'),
                Tab(text: 'My Complaints'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewComplaintTab(cardColor, textColor, isDark, backgroundColor),
                _buildMyComplaintsTab(cardColor, textColor, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewComplaintTab(
      Color cardColor, Color textColor, bool isDark, Color backgroundColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ComplaintProgressIndicator(
            isDark: isDark,
            textColor: textColor,
            currentStep: _currentStep,
            totalSteps: _getTotalSteps(),
            stepTitle: _getStepTitle(),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: _buildCurrentStep(cardColor, textColor, isDark),
            ),
          ),
          const SizedBox(height: 20),
          ComplaintNavigationButtons(
            isDark: isDark,
            currentStep: _currentStep,
            canGoNext: _canGoNext(),
            onPrevious: _previousStep,
            onNext: _nextStep,
            onSubmit: _submitComplaint,
          ),
        ],
      ),
    );
  }

  int _getTotalSteps() {
    int totalSteps = 2;
    if (_needsSubCategory()) totalSteps++;
    if (_needsIssueType()) totalSteps++;
    return totalSteps;
  }

  bool _canGoNext() {
    return (_currentStep == 0 && _complaintType != null) ||
        (_currentStep == 1 && _subCategory != null) ||
        (_currentStep == 2 && _issueType != null) ||
        _currentStep == 3;
  }

  Widget _buildMyComplaintsTab(Color cardColor, Color textColor, bool isDark) {
    if (_isLoadingComplaints) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xffFE724C),
        ),
      );
    }

    if (_pastComplaints.isEmpty) {
      return EmptyComplaintsView(textColor: textColor);
    }

    return RefreshIndicator(
      onRefresh: _loadPastComplaints,
      color: const Color(0xffFE724C),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _pastComplaints.length,
        itemBuilder: (context, index) {
          final complaint = _pastComplaints[index];
          return GestureDetector(
            onTap: () => _showComplaintDetails(complaint, cardColor, textColor, isDark),
            child: ComplaintCard(
              complaint: complaint,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  void _showComplaintDetails(
    UserComplaintModel complaint,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Complaint Details',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _buildComplaintDetailsContent(complaint, textColor, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintDetailsContent(
    UserComplaintModel complaint,
    Color textColor,
    bool isDark,
  ) {
    final statusColor = _getComplaintStatusColor(complaint);
    final statusIcon = _getComplaintStatusIcon(complaint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 20, color: statusColor),
              const SizedBox(width: 8),
              Text(
                complaint.complaintStatus.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Complaint Type
        _buildDetailSection(
          'Complaint Type',
          complaint.getComplaintType(),
          textColor,
          Icons.report_problem_outlined,
        ),

        const SizedBox(height: 20),

        // Description
        _buildDetailSection(
          'Description',
          complaint.complaintDescription.isEmpty
              ? 'No description provided'
              : complaint.complaintDescription,
          textColor,
          Icons.description_outlined,
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _buildDetailSection(
                'Hostel',
                complaint.hostel.isEmpty ? 'N/A' : complaint.hostel,
                textColor,
                Icons.apartment,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailSection(
                'Room',
                complaint.roomNumber.isEmpty ? 'N/A' : complaint.roomNumber,
                textColor,
                Icons.meeting_room,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Complaint Data (All dynamic fields)
        if (complaint.complaintData.isNotEmpty) ...[
          Text(
            'Additional Details',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: complaint.complaintData.entries.map((entry) {
                final key = _formatFieldName(entry.key);
                final value = entry.value?.toString() ?? 'N/A';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          key,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          value,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Dates
        _buildDetailSection(
          'Submitted On',
          complaint.getFormattedDate(),
          textColor,
          Icons.calendar_today,
        ),

        if (complaint.resolvedAt != null) ...[
          const SizedBox(height: 20),
          _buildDetailSection(
            'Resolved On',
            _formatDate(complaint.resolvedAt!),
            Colors.green,
            Icons.check_circle,
          ),
        ],

        const SizedBox(height: 20),

        // Images
        if (complaint.images.isNotEmpty) ...[
          Text(
            'Attachments',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: complaint.images.map((imagePath) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      color: textColor.withOpacity(0.5),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailSection(String label, String value, Color textColor, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: textColor.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  String _formatFieldName(String fieldName) {
    // Convert snake_case to Title Case
    return fieldName
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Color _getComplaintStatusColor(UserComplaintModel complaint) {
    if (complaint.isResolved()) {
      return Colors.green;
    } else if (complaint.isInProgress()) {
      return Colors.orange;
    } else {
      return Colors.orange;
    }
  }

  IconData _getComplaintStatusIcon(UserComplaintModel complaint) {
    if (complaint.isResolved()) {
      return Icons.check_circle;
    } else if (complaint.isInProgress()) {
      return Icons.hourglass_bottom;
    } else {
      return Icons.pending;
    }
  }

  String _getStepTitle() {
    if (_currentStep == 0) return 'Select Complaint Type';
    if (_currentStep == 1) return 'Select Category';
    if (_currentStep == 2) return 'Select Issue';
    return 'Complaint Details';
  }

  Widget _buildCurrentStep(Color cardColor, Color textColor, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildComplaintTypeStep(cardColor, textColor, isDark);
      case 1:
        return _buildSubCategoryStep(cardColor, textColor, isDark);
      case 2:
        return _buildIssueTypeStep(cardColor, textColor, isDark);
      case 3:
        return _buildDetailsStep(cardColor, textColor, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildComplaintTypeStep(Color cardColor, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What type of complaint do you want to register?',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 24),
        ...HostelComplaintData.complaintTypes.map(
          (type) => ComplaintOptionCard(
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
            label: type,
            isSelected: _complaintType == type,
            onTap: () => setState(() => _complaintType = type),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryStep(Color cardColor, Color textColor, bool isDark) {
    final subCategoryList = HostelComplaintData.getSubCategories(_complaintType);

    if (subCategoryList == null || subCategoryList.isEmpty) {
      return const SizedBox.shrink();
    }

    final categoryLabel = HostelComplaintData.getSubCategoryLabel(_complaintType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select $categoryLabel',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 24),
        ...subCategoryList.map(
          (subCat) => ComplaintOptionCard(
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
            label: subCat,
            isSelected: _subCategory == subCat,
            onTap: () => setState(() {
              _subCategory = subCat;
              _issueType = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueTypeStep(Color cardColor, Color textColor, bool isDark) {
    final issueList = HostelComplaintData.getIssueTypes(_complaintType, _subCategory);

    if (issueList == null || issueList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is the specific issue?',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 24),
        ...issueList.map(
          (issue) => ComplaintOptionCard(
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
            label: issue,
            isSelected: _issueType == issue,
            onTap: () => setState(() => _issueType = issue),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(Color cardColor, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _descriptionController,
                maxLines: 6,
                style: GoogleFonts.inter(color: textColor),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: 'Describe your complaint in detail...',
                  hintStyle: GoogleFonts.inter(
                    color: textColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        PhotoPickerSection(
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
          files: _files,
          onPickImage: _pickImage,
          onRemoveFile: (index) => setState(() => _files.removeAt(index)),
        ),
      ],
    );
  }
}
