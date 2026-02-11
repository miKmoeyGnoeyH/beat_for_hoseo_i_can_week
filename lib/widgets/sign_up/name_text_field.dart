import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpNameTextField extends StatelessWidget {
  const SignUpNameTextField({
    super.key,
    required this.nameController,
    required this.flagController,
  });

  final TextEditingController nameController;
  final void Function(bool) flagController;

  @override
  Widget build(BuildContext context) {
    return BEATTextFormField(
      controller: nameController,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      labelText: LocalizationService.instance.signUpName,
      hintText: LocalizationService.instance.signUpNameHint,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return LocalizationService.instance.errorNameIsEmpty;
        } else if (!intlNameRegExp.hasMatch(value)) {
          return LocalizationService.instance.errorInavailableNameMessage2;
        } else if (profanityFilter.hasMatch(value)) {
          return LocalizationService.instance.errorInavailableNameMessage;
        } else {
          return null;
        }
      },
      onChanged: (_) {
        flagController(false);
      },
    );
  }
}
