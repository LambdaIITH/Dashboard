import 'package:dashbaord/models/user_complaint_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintCard extends StatelessWidget {
  final UserComplaintModel complaint;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(statusColor, statusIcon),
          const SizedBox(height: 12),
          _buildDescription(),
          const SizedBox(height: 12),
          _buildMetadata(),
          if (complaint.resolvedAt != null) ...[
            const SizedBox(height: 8),
            _buildResolvedDate(),
          ],
          const SizedBox(height: 12),
          // Tap to expand indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.expand_more,
                size: 16,
                color: textColor.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                'Tap to view details',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color statusColor, IconData statusIcon) {
    return Row(
      children: [
        Expanded(
          child: Text(
            complaint.getComplaintType(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                size: 14,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                complaint.complaintStatus.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      complaint.complaintDescription,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: textColor.withOpacity(0.8),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: textColor.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          complaint.getFormattedDate(),
          style: GoogleFonts.inter(
            fontSize: 12,
            color: textColor.withOpacity(0.6),
          ),
        ),
        if (complaint.images.isNotEmpty) ...[
          const SizedBox(width: 16),
          Icon(
            Icons.image,
            size: 14,
            color: textColor.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            '${complaint.images.length} ${complaint.images.length == 1 ? 'photo' : 'photos'}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResolvedDate() {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 14,
          color: Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          'Resolved on ${_formatDate(complaint.resolvedAt!)}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (complaint.isResolved()) {
      return Colors.green;
    } else if (complaint.isInProgress()) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    if (complaint.isResolved()) {
      return Icons.check_circle;
    } else if (complaint.isInProgress()) {
      return Icons.hourglass_bottom;
    } else {
      return Icons.pending;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
