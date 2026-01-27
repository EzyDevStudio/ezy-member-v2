import 'package:flutter/material.dart';

class CustomFab extends StatelessWidget {
  final ScrollController controller;

  const CustomFab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    backgroundColor: Theme.of(context).colorScheme.tertiary,
    foregroundColor: Theme.of(context).colorScheme.onTertiary,
    onPressed: () => controller.animateTo(0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
    child: Icon(Icons.keyboard_arrow_up_rounded),
  );
}
