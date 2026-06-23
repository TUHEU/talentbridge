// lib/shared/widgets/tb_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class TbTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? formatters;
  final int? maxLines;
  final int? maxLength;
  final String? helperText;
  final FocusNode? focusNode;

  const TbTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.formatters,
    this.maxLines = 1,
    this.maxLength,
    this.helperText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:       controller,
      obscureText:      obscure,
      keyboardType:     keyboardType,
      textInputAction:  textInputAction,
      validator:        validator,
      onChanged:        onChanged,
      onFieldSubmitted: onSubmitted,
      readOnly:         readOnly,
      onTap:            onTap,
      inputFormatters:  formatters,
      maxLines:         maxLines,
      maxLength:        maxLength,
      focusNode:        focusNode,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkText
            : AppColors.grey900,
      ),
      decoration: InputDecoration(
        labelText:    label,
        hintText:     hint,
        helperText:   helperText,
        helperMaxLines: 2,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20)
            : null,
        suffixIcon: suffix,
        counterText: '',
      ),
    );
  }
}
