import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:beat/shared/index.dart';
import 'package:beat/widgets/index.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController authCodeController = TextEditingController();
  final _pwSectionFormKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validatePasswordController =
      TextEditingController();

  bool _isStudentIdValidated = false;
  bool _isPasswordValidated = false;

  void setIsStudentIdValidated(bool value) {
    setState(() {
      _isStudentIdValidated = value;
    });
  }

  void setIsPasswordValidated(bool value) {
    setState(() {
      _isPasswordValidated = value;
    });
  }

  Future<void> changePassword() async {
    if (!(_isStudentIdValidated && _isPasswordValidated)) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorResetPasswordFailedTitle,
          message: LocalizationService.instance.errorResetPasswordEmptyField,
        ),
      );
      return;
    }

    try {
      final String authorization =
          AuthenticationController.to.state!.authorization;
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 500));
          return await APIService().post(
            endpoint: DotEnvService.instance.resetPassword,
            header: {
              "Content-Type": "application/json",
              "Authorization": authorization,
            },
            body: jsonEncode({
              "studentId": studentIdController.text,
              "authCode": authCodeController.text,
              "newPassword": passwordController.text,
            }),
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      log(response.body);

      switch (response.statusCode) {
        case 200:
          log("change password: statusCode: ${response.statusCode}");
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService.instance.changePasswordComplete,
              message:
                  LocalizationService.instance.changePasswordCompleteContent,
              onConfirm: () async {
                await StepCountController.to.stopService();
                AuthenticationController.to.SignOut();
                Get.offAllNamed(BEATRoute.signIn);
              },
            ),
          );
          break;
        case 400:
          throw BEATException(
            title: LocalizationService.instance.errorResetPasswordFailedTitle,
            message:
                LocalizationService.instance.errorResetPasswordFailedContent,
          );
        case 401:
          throw BEATTokenExpired();
        default:
          throw Exception();
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATTokenExpired {
      await AuthenticationController.to.reissueToken();
      await changePassword();
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
          title: LocalizationService.instance.errorResetPasswordFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        FocusManager.instance.primaryFocus?.unfocus();

        if (_pwSectionFormKey.currentState!.validate()) {
          setIsPasswordValidated(true);
        } else {
          setIsPasswordValidated(false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.designWhite,
        appBar: AppBar(
          title: Text(
            LocalizationService.instance.changePasswordTitle,
            style: AppTextTheme.subtitle2,
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.commonWhite,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset(
              BEATAssets.svg.backArrow,
              width: 24.w,
              height: 24.w,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.5.w),
            child: Container(height: 0.5.w, color: AppColors.common300),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 16.w)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: BEATShadowContainer(
                    contentPadding: EdgeInsetsGeometry.all(16.w),
                    shadowBlurRadius: 30.w,
                    shadowSpreadRadius: -25.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CPSIDSection(
                          studentIdController: studentIdController,
                          authCodeController: authCodeController,
                          flagController: setIsStudentIdValidated,
                        ),
                        SizedBox(height: 30.w),
                        Form(
                          key: _pwSectionFormKey,
                          child: PWSection(
                            flagController: setIsPasswordValidated,
                            passwordController: passwordController,
                            validatePasswordController:
                                validatePasswordController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.w)),
            ],
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: (_isStudentIdValidated && _isPasswordValidated)
              ? changePassword
              : () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.5.w, color: AppColors.common300),
              ),
            ),
            child: BottomAppBar(
              color: (_isStudentIdValidated && _isPasswordValidated)
                  ? AppColors.primary
                  : AppColors.common200,
              height: 56.w,
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: AutoSizeText(
                    LocalizationService.instance.changePasswordTitle,
                    style: (_isStudentIdValidated && _isPasswordValidated)
                        ? AppTextTheme.title1.designWhite
                        : AppTextTheme.title1.common300,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
