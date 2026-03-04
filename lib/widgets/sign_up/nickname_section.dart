import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../shared/index.dart';

class NicknameSection extends StatefulWidget {
  const NicknameSection({
    super.key,
    required this.controller,
    required this.flagController,
  });

  @override
  State<NicknameSection> createState() => _NicknameSectionState();

  final TextEditingController controller;
  final void Function(bool) flagController;
}

class _NicknameSectionState extends State<NicknameSection> {
  Future<void> onTextButtonTap() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final String value = widget.controller.text;

    if (value.isEmpty) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorValidateNicknameFailedTitle,
          message: LocalizationService.instance.errorNicknameIsEmpty,
        ),
      );
      return;
    } else if (koreanInitialConsonantRegExp.hasMatch(value)) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorValidateNicknameFailedTitle,
          message:
              LocalizationService.instance.errorNicknameHasInitialConsonant,
        ),
      );
      return;
    } else if (!intlNameRegExp.hasMatch(value)) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorValidateNicknameFailedTitle,
          message:
              LocalizationService.instance.errorNicknameInavailableMessage2,
        ),
      );
      return;
    } else if (profanityFilter.hasMatch(value)) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorValidateNicknameFailedTitle,
          message: LocalizationService.instance.errorNicknameInavailableMessage,
        ),
      );
      return;
    }

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          return await APIService().get(
            endpoint:
                "${DotEnvService.instance.validateNickname}?nickname=$value",
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      switch (response.statusCode) {
        case 200:
          widget.flagController(true);
          setState(() {
            _isValueValidated = true;
          });
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService
                  .instance
                  .signUpValidateNicknameSuccessTitle,
              message: LocalizationService
                  .instance
                  .signUpValidateNicknameSuccessContent,
            ),
          );
          break;
        case 400:
          throw BEATException(
            title:
                LocalizationService.instance.errorValidateNicknameFailedTitle,
            message: response.body,
          );
        default:
          throw BEATException(
            title:
            LocalizationService.instance.errorValidateNicknameFailedTitle,
            message: response.body,
          );
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATException catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(e);
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(
        BEATException(
          title: LocalizationService.instance.errorValidateNicknameFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

  final int minLength = 2;
  final int maxLength = 20;

  bool _isInputLengthValid = false;
  bool _isValueValidated = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BEATTextFormField(
          controller: widget.controller,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          labelText: LocalizationService.instance.signUpNickname,
          hintText: LocalizationService.instance.signUpNicknameHint,
          maxLength: maxLength,
          onChanged: (value) {
            if (value.length >= minLength) {
              setState(() {
                _isInputLengthValid = true;
                _isValueValidated = false;
              });
            } else {
              setState(() {
                _isInputLengthValid = false;
                _isValueValidated = false;
              });
            }
            widget.flagController(false);
          },
        ),
        SizedBox(height: 10.w),
        BEATTextButton(
          enabled: _isInputLengthValid && !_isValueValidated,
          text: _isValueValidated
              ? LocalizationService.instance.signUpNicknameValidated
              : LocalizationService.instance.signUpValidateNickname,
          buttonColor: AppColors.primary,
          contentPadding: EdgeInsets.symmetric(vertical: 14.w),
          onTap: onTextButtonTap,
        ),
      ],
    );
  }
}
