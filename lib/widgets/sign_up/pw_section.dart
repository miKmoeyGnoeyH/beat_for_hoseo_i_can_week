import 'package:beat/shared/regexp/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class PWSection extends StatefulWidget {
  const PWSection({
    super.key,
    required this.flagController,
    required this.passwordController,
    required this.validatePasswordController,
  });

  @override
  State<PWSection> createState() => _PWSectionState();

  final void Function(bool) flagController;
  final TextEditingController passwordController;
  final TextEditingController validatePasswordController;
}

class _PWSectionState extends State<PWSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BEATTextFormField(
          controller: widget.passwordController,
          obscureText: true,
          labelText: LocalizationService.instance.signUpPassword,
          hintText: LocalizationService.instance.signUpPasswordHint,
          inputFormatters: [FilteringTextInputFormatter.allow(passwordAllowedChars)],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocalizationService.instance.errorPasswordIsEmpty;
            } else if (!password.hasMatch(value)) {
              return LocalizationService.instance.errorPasswordFormatUnmatch;
            }
            return null;
          },
          onChanged: (_) {
            widget.flagController(false);
          },
        ),
        SizedBox(height: 16.w),
        BEATTextFormField(
          controller: widget.validatePasswordController,
          obscureText: true,
          labelText: LocalizationService.instance.signUpValidatePassword,
          hintText: LocalizationService.instance.signUpValidatePasswordHint,
          inputFormatters: [FilteringTextInputFormatter.allow(passwordAllowedChars)],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocalizationService.instance.errorValidatePasswordIsEmpty;
            } else if (value != widget.passwordController.text) {
              return LocalizationService
                  .instance.errorPasswordNotMatched;
            }
            return null;
          },
          onChanged: (_) {
            widget.flagController(false);
          },
        ),
      ],
    );
  }
}
