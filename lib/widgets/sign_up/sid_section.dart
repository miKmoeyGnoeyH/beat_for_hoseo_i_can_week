import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../shared/index.dart';

class SIDSection extends StatefulWidget {
  const SIDSection({
    super.key,
    required this.controller,
    required this.flagController,
  });

  @override
  State<SIDSection> createState() => _SIDSectionState();

  final TextEditingController controller;
  final void Function(bool) flagController;
}

class _SIDSectionState extends State<SIDSection> {
  final TextEditingController _authCodeController = TextEditingController();

  Future<void> onTextButtonTap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String value = widget.controller.text;

    if (value.isEmpty) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorEmailSendingFailedTitle,
          message: LocalizationService.instance.errorSidIsEmpty,
        ),
      );
      return;
    } else if (!onlyDigits.hasMatch(value)) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorEmailSendingFailedTitle,
          message: LocalizationService.instance.errorInvalidSid,
        ),
      );
      return;
    }

    if (!_isEmailSent) {
      await requestEmail();
      return;
    } else if (!_isValueValidated) {
      await requestVerify();
      return;
    }
  }

  Future<void> requestEmail() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String value = widget.controller.text;

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 100));
          return await APIService().post(
            endpoint:
                "${DotEnvService.instance.requestEmail}?studentId=$value&emailType=SIGN_UP",
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      switch (response.statusCode) {
        case 200:
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService.instance.signUpEmailSentTitle,
              message: LocalizationService.instance.signUpEmailSentMessage(
                value,
              ),
              onConfirm: () => setState(() {
                _isEmailSent = true;
                _isEmailSentOnce = true;
              }),
            ),
          );
          break;
        default:
          throw BEATException(
            title: LocalizationService.instance.errorEmailSendingFailedTitle,
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
          title: LocalizationService.instance.errorEmailSendingFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

  Future<void> requestVerify() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String value = widget.controller.text;

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 100));
          return await APIService().get(
            endpoint: "${DotEnvService.instance.verifyEmail}?studentId=$value",
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
              title: LocalizationService.instance.signUpVerifyEmailSuccessTitle,
              message:
                  LocalizationService.instance.signUpVerifyEmailSuccessContent,
              onConfirm: () => setState(() {
                _isEmailSentOnce = false;
              }),
            ),
          );
          break;
        default:
          throw BEATException(
            title: LocalizationService.instance.errorVerifyEmailFailedTitle,
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
          title: LocalizationService.instance.errorVerifyEmailFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

  final int minSidLength = 8;
  final int maxSidLength = 8;

  final int minAuthCodeLength = 6;
  final int maxAuthCodeLength = 6;

  bool _isSidInputLengthValid = false;
  bool _isEmailSent = false;
  bool _isEmailSentOnce = false;
  bool _isValueValidated = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BEATTextFormField(
          controller: widget.controller,
          textInputType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          labelText: LocalizationService.instance.signUpStudentId,
          hintText: LocalizationService.instance.signUpStudentIdHint,
          maxLength: maxSidLength,
          onChanged: (value) {
            if (value.length >= minSidLength) {
              setState(() {
                _isSidInputLengthValid = true;
                _isEmailSent = false;
                _isValueValidated = false;
              });
            } else {
              setState(() {
                _isSidInputLengthValid = false;
                _isEmailSent = false;
                _isValueValidated = false;
              });
            }
            _authCodeController.clear();
            widget.flagController(false);
          },
        ),
        // if (_isEmailSentOnce)
        //   AnimatedSwitcher(
        //     duration: Duration(milliseconds: 200),
        //     transitionBuilder: (child, animation) {
        //       final offsetAnimation = Tween<Offset>(
        //         begin: Offset(0, -0.5),
        //         end: Offset.zero,
        //       ).animate(animation);
        //
        //       return ClipRect(
        //         child: SlideTransition(
        //           position: offsetAnimation,
        //           child: FadeTransition(opacity: animation, child: child),
        //         ),
        //       );
        //     },
        //     child: _isEmailSentOnce
        //         ? Column(
        //             key: const ValueKey("authcode_field"),
        //             children: [
        //               SizedBox(height: 10.w),
        //               BEATTextFormField(
        //                 key: const ValueKey("authcode_textfield"),
        //                 enabled: !_isValueValidated,
        //                 controller: _authCodeController,
        //                 hintText:
        //                     LocalizationService.instance.signUpAuthcodeHint,
        //                 maxLength: maxAuthCodeLength,
        //                 obscureText: true,
        //                 onChanged: (value) {
        //                   if (value.length >= minAuthCodeLength) {
        //                     setState(() {
        //                       _isValueValidated = false;
        //                     });
        //                   } else {
        //                     setState(() {
        //                       _isValueValidated = false;
        //                     });
        //                   }
        //                   widget.flagController(false);
        //                 },
        //               ),
        //             ],
        //           )
        //         : const SizedBox(key: ValueKey("empty")),
        //   ),
        SizedBox(height: 10.w),
        BEATTextButton(
          enabled:
              _isSidInputLengthValid && (!_isEmailSent || !_isValueValidated),
          text: _isValueValidated
              ? LocalizationService.instance.signUpEmailVerified
              : _isEmailSent
              ? LocalizationService.instance.signUpEmailSent
              : LocalizationService.instance.signUpValidateMail,
          buttonColor: AppColors.primary,
          contentPadding: EdgeInsets.symmetric(vertical: 14.w),
          onTap: onTextButtonTap,
        ),
      ],
    );
  }
}
