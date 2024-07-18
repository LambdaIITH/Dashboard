import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetName;
  final double? size;

  const SvgIcon(this.assetName, {Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return size != null
        ? SvgPicture.asset(
            assetName,
            height: size,
            width: size,
          )
        : SvgPicture.asset(
            assetName,
          );
  }
}