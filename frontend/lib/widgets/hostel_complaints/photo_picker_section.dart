import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoPickerSection extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final bool isDark;
  final List<String> files;
  final VoidCallback onPickImage;
  final Function(int) onRemoveFile;

  const PhotoPickerSection({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
    required this.files,
    required this.onPickImage,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (Optional)',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload up to 5 supported files. Max 10 MB per file.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: textColor.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        if (files.length < 5) _buildUploadButton(),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...files.asMap().entries.map((entry) => _buildFileCard(entry.key, entry.value)),
        ],
      ],
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: const Color(0xffFE724C).withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to add photo',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG up to 10MB',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(int index, String filePath) {
    final fileName = filePath.split('/').last.split('\\').last;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffFE724C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image,
              color: Color(0xffFE724C),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => onRemoveFile(index),
            color: textColor.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
