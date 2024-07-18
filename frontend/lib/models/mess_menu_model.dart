class MessMenuModel {
  final Map<String, DayMenu> ldh;
  final Map<String, DayMenu> udh;
  final Map<String, AdditionalMenu> ldhAdditional;
  final Map<String, AdditionalMenu> udhAdditional;

  MessMenuModel({
    required this.ldh,
    required this.udh,
    required this.ldhAdditional,
    required this.udhAdditional,
  });

  factory MessMenuModel.fromJson(Map<String, dynamic> json) {
    return MessMenuModel(
      ldh: (json['LDH'] as Map<String, dynamic>).map((key, value) => MapEntry(key, DayMenu.fromJson(value))),
      udh: (json['UDH'] as Map<String, dynamic>).map((key, value) => MapEntry(key, DayMenu.fromJson(value))),
      ldhAdditional: (json['LDH Additional'] as Map<String, dynamic>).map((key, value) => MapEntry(key, AdditionalMenu.fromJson(value))),
      udhAdditional: (json['UDH Additional'] as Map<String, dynamic>).map((key, value) => MapEntry(key, AdditionalMenu.fromJson(value))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LDH': ldh.map((key, value) => MapEntry(key, value.toJson())),
      'UDH': udh.map((key, value) => MapEntry(key, value.toJson())),
      'LDH Additional': ldhAdditional.map((key, value) => MapEntry(key, value.toJson())),
      'UDH Additional': udhAdditional.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class DayMenu {
  final List<String> breakfast;
  final List<String> lunch;
  final List<String> snacks;
  final List<String> dinner;

  DayMenu({
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });

  factory DayMenu.fromJson(Map<String, dynamic> json) {
    return DayMenu(
      breakfast: List<String>.from(json['Breakfast']),
      lunch: List<String>.from(json['Lunch']),
      snacks: List<String>.from(json['Snacks']),
      dinner: List<String>.from(json['Dinner']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Breakfast': breakfast,
      'Lunch': lunch,
      'Snacks': snacks,
      'Dinner': dinner,
    };
  }
}

class AdditionalMenu {
  final List<String> breakfast;
  final List<String> lunch;
  final List<String> snacks;
  final List<String> dinner;

  AdditionalMenu({
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });

  factory AdditionalMenu.fromJson(Map<String, dynamic> json) {
    return AdditionalMenu(
      breakfast: List<String>.from(json['Breakfast']),
      lunch: List<String>.from(json['Lunch']),
      snacks: List<String>.from(json['Snacks']),
      dinner: List<String>.from(json['Dinner']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Breakfast': breakfast,
      'Lunch': lunch,
      'Snacks': snacks,
      'Dinner': dinner,
    };
  }
}
