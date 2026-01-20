import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchPressed;

  const StandardAppBar({super.key, required this.title, this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: context.theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: context.theme.iconTheme,

      actions: [
        if (onSearchPressed != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.05,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              onPressed: onSearchPressed,
            ),
          ),
        builderMenuButton(context),
      ],
    );
  }

  Widget builderMenuButton(BuildContext context) {
    return Builder(
      builder: (scaffoldContext) => IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: context.theme.colorScheme.primary,
        ),
        onPressed: () {
          Scaffold.of(scaffoldContext).openEndDrawer();
        },
      ),
    );
  }

  // Esto es necesario para que funcione como un AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
