import 'package:flutter/material.dart';

class HostelComplaintsScreen extends StatefulWidget {
  const HostelComplaintsScreen({super.key});

  @override
  State<HostelComplaintsScreen> createState() => _HostelComplaintsScreenState();
}

class _HostelComplaintsScreenState extends State<HostelComplaintsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _complaintType;
  String? _location;
  List<String> _files = [];

  final List<String> _complaintTypes = const [
    'Electrical',
    'Civil',
    'Washing Machine',
    'Water Purifier',
    'Furniture',
    'Cleaning',
    'Pest Control',
    'LAN Issue',
  ];

  final List<String> _locations = const [
    'Room',
    'Washroom',
    'Toilets and urinals',
    'Pantry Area',
    'Common Area',
  ];

  bool _showLocation() => _complaintType == 'Electrical' || _complaintType == 'Civil';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hostel Complaints',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTextField('Email', 'Enter your email', TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField('Contact No', 'Enter contact number', TextInputType.phone),
            const SizedBox(height: 16),
            _buildDropdown(
              'Complaint Type',
              'Select complaint type',
              _complaintTypes,
              _complaintType,
              (val) => setState(() {
                _complaintType = val;
                _location = null;
              }),
            ),
            if (_showLocation()) ...[
              const SizedBox(height: 16),
              _buildDropdown(
                '${_complaintType} Location',
                'Select location',
                _locations,
                _location,
                (val) => setState(() => _location = val),
              ),
            ],
            const SizedBox(height: 16),
            _buildTextField('Description', 'Describe your complaint in detail', TextInputType.multiline, maxLines: 5),
            const SizedBox(height: 16),
            _buildPhotoSection(),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Complaint submitted successfully'),
                        backgroundColor: Colors.green[600],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Submit Complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextInputType type, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            keyboardType: type,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: hint,
            ),
            validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String hint, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: hint,
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
            dropdownColor: Colors.white,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
            validator: (val) => val == null ? 'Required field' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Upload up to 5 supported files. Max 10 MB per file.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 12),
        if (_files.length < 5)
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                // TODO: Implement actual file picker
                // Example: Use image_picker or file_picker package
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Add File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
          ),
        if (_files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._files.asMap().entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, color: Colors.orange[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _files.removeAt(entry.key)),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}