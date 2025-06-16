import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final VoidCallback?
      onLeadingPressed; // NEW: Optional callback for leading button

  const CustomAppBar({
    super.key,
    this.actions,
    this.onLeadingPressed, // Initialize new parameter
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      // If onLeadingPressed is provided, use it. Otherwise, fallback to canPop() logic.
      leading: onLeadingPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: onLeadingPressed, // Use the provided callback
            )
          : Navigator.of(context).canPop() // Original logic for pushed routes
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(); // Navigate back
                  },
                )
              : null, // No leading widget if no callback and cannot pop
      title: const SizedBox.shrink(),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
