import 'package:dashbaord/models/emergency_contact_model.dart';

const List<String> emergencyCategories = [
  'SECURITY',
  'DISPENSARY',
  'HOSTEL',
  'EXTERNAL NUMBERS',
];

const List<EmergencyContact> emergencyContacts = [
  // SECURITY
  EmergencyContact(
    category: 'SECURITY',
    name: 'Security Control Room',
    contact: '040 2359 6813',
    mobile: '8331036114',
  ),
  EmergencyContact(
    category: 'SECURITY',
    name: 'Main Gate, Acad Block \'A\'',
    contact: '040 2359 6817',
  ),
  EmergencyContact(
    category: 'SECURITY',
    name: 'Hostel Block \'F\' Security',
    contact: '040 2359 6820',
    mobile: '8331036104',
  ),
  EmergencyContact(
    category: 'SECURITY',
    name: 'Girls Hostel Block',
    contact: '040 2359 6821',
    mobile: '8331036105',
  ),
  EmergencyContact(
    category: 'SECURITY',
    name: 'Security Office',
    contact: '040 2359 6812',
  ),

  // DISPENSARY
  EmergencyContact(
    category: 'DISPENSARY',
    name: 'Clinic',
    contact: '040 2359 6828',
    mobile: '8331036101',
  ),
  EmergencyContact(
    category: 'DISPENSARY',
    name: 'Duty Ambulance Driver',
    mobile: '8331036100',
  ),
  EmergencyContact(
    category: 'DISPENSARY',
    name: 'ICU on Wheels',
    mobile: '8688061813',
  ),

  // HOSTEL
  EmergencyContact(
    category: 'HOSTEL',
    name: 'Hostel Office',
    contact: '040 2359 6833',
  ),
  EmergencyContact(
    category: 'HOSTEL',
    name: 'Girls Hostel Block \'A\'',
    mobile: '8331036105',
  ),

  // EXTERNAL NUMBERS
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'Sri Balaji Hospital (Kandi)',
    contact: '040 49404940',
  ),
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'Sri Balaji Hospital (Kandi)',
    mobile: '78934 01401',
  ),
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'Fire Station (Sangareddy)',
    contact: '08455 27629',
  ),
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'Fire Station (Sangareddy)',
    mobile: '99637 48770',
  ),
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'Fire Station (Patancheru)',
    contact: '101 / 08455 242099',
  ),
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'Govt. Ambulance',
    contact: '108',
  ),
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'Police Station, Kandi',
    contact: '100 / 08455 276772',
  ),
  EmergencyContact(
    category: 'EXTERNAL NUMBERS',
    name: 'S.I. Police, Kandi',
    contact: '94906 17033',
  ),
];
