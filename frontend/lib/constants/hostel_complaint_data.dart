class HostelComplaintData {
  static const List<String> complaintTypes = [
    'Electrical',
    'Civil',
    'Washing Machine',
    'Water Purifier',
    'Furniture',
    'Cleaning',
    'Pest Control',
    'LAN Issue',
  ];

  static const Map<String, List<String>> subCategories = {
    'Electrical': [
      'Room',
      'Washroom',
      'Toilets and urinals',
      'Pantry Area',
      'Common Area',
    ],
    'Civil': [
      'Room',
      'Washroom',
      'Toilets and urinals',
      'Pantry Area',
      'Common Area',
    ],
    'Furniture': [
      'Need a chair',
      'Need a table',
      'Cot replacement',
    ],
  };

  static const Map<String, Map<String, List<String>>> issueTypes = {
    'Electrical': {
      'Room': [
        'Tube light issue / replacement',
        'Fan issue / replacement',
        'Switch board issue / replacement',
        'Socket issue / replacement',
        'Switches issue / replacement',
        'Fan regulator issue / replacement',
        'No power in room',
        'No power in pod',
        'Radiant cooling issue / not working',
      ],
      'Washroom': [
        'Light issue / replacement',
        'Exhaust fan issue / replacement',
        'Switch board issue / replacement',
        'Open wires',
        'Unclosed switch board',
        'Tube light hanging',
        'Water leakage from switch boards',
        'No power in washroom',
        'Hot water issue',
      ],
      'Toilets and urinals': [
        'Light issue / replacement',
        'Exhaust fan issue / replacement (Indian toilet)',
        'Lights issue / replacement (Urinals)',
        'Tube light hanging',
      ],
      'Pantry Area': [
        'No power issue',
        'Switch board issue / replacement',
        'Switches/ Socket issue/ replacement',
      ],
      'Common Area': [
        'Lights issue / replacement',
        'Fan issue / replacement',
        'Lift not working',
      ],
    },
    'Civil': {
      'Room': [
        'Door Issue',
        'Cot issue',
        'Chair repair',
        'Table repair',
        'Table drawer issue',
        'Curtain rod repair / installation',
        'Almirah issue',
        'Tiles damage / replacement',
        'Seepage',
        'Painting',
        'Tiles skirting issue',
        'Door gap fixation',
        'False ceiling issue',
        'Windows repair',
      ],
      'Washroom': [
        'Washbasin leakage / jam',
        'Washbasin tap repair / replacement',
        'Mirror replacement',
        'CFL replacement (above washbasin)',
        'Drain issue',
        'Tiles damaged / replacement',
        'Unavailability of water',
        'Cloth/towel bar broken',
      ],
      'Toilets and urinals': [
        'Flush issue',
        'Health faucet leakage / replacement',
        'Health faucet holder broken / replacement',
        'No flush water',
        'Leakage of water from flush',
        'Ceiling leakage',
        'Urinal Jam',
        'Urinal leakage',
        'Urinal Pot damaged / replacement',
      ],
      'Pantry Area': [
        'Washbasic tap issue',
        'Washbasin jam',
        'Washbasin leakage',
        'Washing machine drain issue',
        'Washing machine tap repair',
        'Water purifier drain issue',
      ],
      'Common Area': [
        'Unavailability of water in block',
        'Drainage issue',
      ],
    },
  };

  static bool hasSubCategory(String? complaintType) {
    return complaintType != null && subCategories.containsKey(complaintType);
  }

  static bool hasIssueType(String? complaintType, String? subCategory) {
    if (complaintType == null || subCategory == null) return false;
    return (complaintType == 'Electrical' || complaintType == 'Civil') &&
        issueTypes[complaintType]?.containsKey(subCategory) == true;
  }

  static List<String>? getSubCategories(String? complaintType) {
    return complaintType != null ? subCategories[complaintType] : null;
  }

  static List<String>? getIssueTypes(String? complaintType, String? subCategory) {
    if (complaintType == null || subCategory == null) return null;
    return issueTypes[complaintType]?[subCategory];
  }

  static String getSubCategoryLabel(String? complaintType) {
    if (complaintType == 'Furniture') {
      return 'Furniture Type';
    }
    return '$complaintType Location';
  }
}
