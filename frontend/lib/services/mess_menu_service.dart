import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:dashbaord/models/mess_menu_model.dart';

class MessMenuService {
  static Future<MessMenuModel> loadWeek(int week) async {
    final fileName = week.isOdd ? 'odd.json' : 'even.json';
    
    final jsonString =
        await rootBundle.loadString('assets/mess/$fileName');

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return MessMenuModel.fromJson(data);
  }

  static int getCurrentWeek() {
    final now = DateTime.now();

    int mondays = 0;

    for (int day = 1; day <= now.day; day++) {
      final date = DateTime(now.year, now.month, day);

      if (date.weekday == DateTime.monday) {
        mondays++;
      }
    }

    if (mondays == 0) {
      mondays = 1;
    }

    return ((mondays - 1) % 4) + 1;
  }

  static Future<MessMenuModel> loadCurrentMenu() {
    return loadWeek(getCurrentWeek());
  }
}