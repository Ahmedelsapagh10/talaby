import 'package:flutter/material.dart';

class RoutePlaceholderPage extends StatelessWidget {
  const RoutePlaceholderPage({super.key, required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(message ?? title)),
  );
}
