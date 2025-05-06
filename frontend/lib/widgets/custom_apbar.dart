import 'package:dashbaord/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 0,
      leadingWidth: 40,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: context.customColors.customAccentColor,
            size: 28,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 25.0,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
        ),
      ),
      actions: actions,
      bottom: bottom ?? PreferredSize(preferredSize: Size.zero, child: SizedBox.shrink()),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}