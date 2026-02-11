import 'package:beat/shared/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BEATTextFormField extends StatelessWidget {
  const BEATTextFormField({
    super.key,
    this.labelText,
    this.enabled = true,
    this.controller,
    this.textInputType,
    this.validator,
    this.autovalidateMode,
    this.inputFormatters,
    this.maxLength,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText != null
            ? Text(labelText!, style: AppTextTheme.subtitle3)
            : SizedBox.shrink(),
        labelText != null ? SizedBox(height: 10.w) : SizedBox.shrink(),
        TextFormField(
          enabled: enabled,
          controller: controller,
          keyboardType: textInputType,
          validator: validator,
          autovalidateMode: autovalidateMode,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: "",
            suffixIcon: suffixIcon,
          ),
          obscureText: obscureText,
          onChanged: onChanged,
        ),
      ],
    );
  }

  final String? labelText;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
}
