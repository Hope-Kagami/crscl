import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType keyboardType;
  final Color? fillColor;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: fillColor ?? Colors.white,
      ),
      enabled: enabled,
      keyboardType: keyboardType,
    );
  }
}
