import 'package:dashbaord/constants/emergency_contacts_data.dart';
import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/models/emergency_contact_model.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  /// Groups the flat contact list by category.
  Map<String, List<EmergencyContact>> _groupByCategory() {
    final Map<String, List<EmergencyContact>> grouped = {};
    for (final cat in emergencyCategories) {
      grouped[cat] = emergencyContacts.where((c) => c.category == cat).toList();
    }
    return grouped;
  }

  /// Returns the icon for a given category.
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'SECURITY':
        return Icons.shield_outlined;
      case 'DISPENSARY':
        return Icons.local_hospital_outlined;
      case 'HOSTEL':
        return Icons.apartment_outlined;
      case 'EXTERNAL NUMBERS':
        return Icons.phone_in_talk_outlined;
      default:
        return Icons.contacts_outlined;
    }
  }

  /// Returns the accent colour for a given category.
  Color _categoryColor(String category) {
    switch (category) {
      case 'SECURITY':
        return const Color(0xFF4A90D9);
      case 'DISPENSARY':
        return const Color(0xFFE85D3A);
      case 'HOSTEL':
        return const Color(0xFF6DBE45);
      case 'EXTERNAL NUMBERS':
        return const Color(0xFFF5A623);
      default:
        return const Color(0xFF4A90D9);
    }
  }

  Future<void> _makePhoneCall(String number) async {
    // Strip spaces and slashes for dialling
    final cleaned = number.replaceAll(' ', '').split('/').first.trim();
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByCategory();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Emergency Contacts'),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: emergencyCategories.length,
          itemBuilder: (context, index) {
            final category = emergencyCategories[index];
            final contacts = grouped[category]!;
            final color = _categoryColor(category);
            final icon = _categoryIcon(category);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: context.customColors.customContainerColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: context.customColors.customShadowColor,
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Theme(
                  // Override divider colour so ExpansionTile doesn't show ugly lines
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    title: Text(
                      category,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        letterSpacing: 0.6,
                      ),
                    ),
                    subtitle: Text(
                      '${contacts.length} contacts',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    iconColor: color,
                    collapsedIconColor: color,
                    children: [
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                      ...contacts.map((c) => _ContactTile(
                            contact: c,
                            accentColor: color,
                            onCall: _makePhoneCall,
                          )),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final Color accentColor;
  final Future<void> Function(String) onCall;

  const _ContactTile({
    required this.contact,
    required this.accentColor,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.grey.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Contact info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (contact.contact != null)
                    _PhoneChip(
                      label: 'Landline',
                      number: contact.contact!,
                      icon: Icons.phone_outlined,
                      color: accentColor,
                      onTap: () => onCall(contact.contact!),
                    ),
                  if (contact.contact != null && contact.mobile != null)
                    const SizedBox(height: 4),
                  if (contact.mobile != null)
                    _PhoneChip(
                      label: 'Mobile',
                      number: contact.mobile!,
                      icon: Icons.smartphone_outlined,
                      color: accentColor,
                      onTap: () => onCall(contact.mobile!),
                    ),
                ],
              ),
            ),
            // Quick‑call button (use first available number)
            IconButton(
              onPressed: () {
                onCall(contact.mobile ?? contact.contact ?? '');
              },
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.call, color: accentColor, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneChip extends StatelessWidget {
  final String label;
  final String number;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PhoneChip({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              decoration: TextDecoration.underline,
              decorationColor: color.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
