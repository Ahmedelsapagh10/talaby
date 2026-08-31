import 'package:flutter/material.dart';
import '../design_system/tokens.dart';
import '../design_system/typography.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF191B1A),
          ),
        ),
        const SizedBox(height: AppTokens.s8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s16,
              vertical: AppTokens.s12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.r4),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: AppTokens.bThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.r4),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: AppTokens.bThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.r4),
              borderSide: const BorderSide(
                color: Color(0xFF191B1A),
                width: AppTokens.bThick,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF191B1A),
          ),
        ),
        const SizedBox(height: AppTokens.s8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          style: AppTypography.bodyMedium,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF191B1A)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s16,
              vertical: AppTokens.s12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.r4),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: AppTokens.bThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.r4),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: AppTokens.bThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.r4),
              borderSide: const BorderSide(
                color: Color(0xFF191B1A),
                width: AppTokens.bThick,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
