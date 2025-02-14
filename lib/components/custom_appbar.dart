import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).appBarTheme;

    return AppBar(
      title: Text(
        title,
        style: theme.titleTextStyle, 
      ),
      centerTitle: theme.centerTitle ?? true, 
      elevation: theme.elevation, 
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: theme.iconTheme?.color ?? Colors.black,
          size: 16,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
