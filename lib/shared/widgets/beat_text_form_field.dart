import 'package:beat/shared/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BEATTextFormField extends StatelessWidget {
  const BEATTextFormField({
    super.key,
    this.labelText,
    this.textInputType,
    this.controller,
    this.maxLength,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText != null
            ? Text(labelText!, style: AppTextTheme.subtitle1)
            : SizedBox.shrink(),
        labelText != null ? SizedBox(height: 4.w) : SizedBox.shrink(),
        TextFormField(
          keyboardType: textInputType,
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText,
            counterText: "",
            suffixIcon: suffixIcon,
          ),
          obscureText: obscureText,
        ),
      ],
    );
  }

  final String? labelText;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final int? maxLength;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
}
