import 'package:dashbaord/constants/app_theme.dart';
import 'package:flutter/material.dart';

extension CustomTheme on BuildContext {
  CustomColors get customColors {
    return Theme.of(this).extension<CustomColors>()!;
  }
}
