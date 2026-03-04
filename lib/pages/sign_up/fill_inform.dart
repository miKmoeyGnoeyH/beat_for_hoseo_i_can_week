import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:beat/shared/index.dart';
import 'package:beat/widgets/index.dart';

class FillInform extends StatefulWidget {
  const FillInform({super.key});

  @override
  State<FillInform> createState() => _FillInformState();
}

class _FillInformState extends State<FillInform> {
  final int selectedCampusIndex = Get.arguments["selectedCampusIndex"];
  final int selectedCollegeIndex = Get.arguments["selectedCollegeIndex"];
  final int selectedDepartmentIndex = Get.arguments["selectedDepartmentIndex"];

  late final String uiCampus;
  late final String uiCollge;
  late final String uiDepartments;

  late final String requestCampus;
  late final String requestCollege;
  late final String requestDepartment;

  final _nameSectionFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final _pwSectionFormKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validatePasswordController =
      TextEditingController();

  late final List<Widget> campusCollegeDepartments;

  bool _isNameValidated = false;
  bool _isNicknameValidated = false;
  bool _isStudentIdValidated = false;
  bool _isPasswordValidated = false;
  String? _signatureBase64;
  bool _isAgreementChecked = false;

  void setIsNameValidated(bool value) {
    setState(() {
      _isNameValidated = value;
    });
  }

  void setIsNicknameValidated(bool value) {
    setState(() {
      _isNicknameValidated = value;
    });
  }

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

  void setSignatureBase64(String? value) {
    setState(() {
      _signatureBase64 = value;
    });
  }

  void setIsAgreementChecked(bool value) {
    setState(() {
      _isAgreementChecked = value;
    });
  }

  Future<void> signUp() async {
    if (!(_isNameValidated &&
        _isNicknameValidated &&
        _isStudentIdValidated &&
        _isPasswordValidated &&
        _signatureBase64 != null &&
        _isAgreementChecked)) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.errorSignUpFailedTitle,
          message: LocalizationService.instance.errorSignUpEmptyField,
        ),
      );
      return;
    }

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 100));
          return await APIService().post(
            endpoint: DotEnvService.instance.signUp,
            header: {"Content-Type": "application/json"},
            body: jsonEncode({
              "campus": requestCampus,
              "department": requestDepartment,
              "studentId": studentIdController.text,
              "name": nameController.text,
              "nickname": nicknameController.text,
              "password": passwordController.text,
              "encodedSignFile": _signatureBase64,
              "privacyConsent": _isAgreementChecked,
            }),
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      log("${response.statusCode} ${response.body}");

      switch (response.statusCode) {
        case 200:
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService.instance.signUpComplete,
              message: LocalizationService.instance.signUpCompleteContent,
              onConfirm: () => Get.offAllNamed(BEATRoute.signIn),
            ),
          );
          break;
        case 400:
          throw BEATException(
            title: LocalizationService.instance.errorSignUpFailedTitle,
            message: response.body,
          );
        default:
          throw BEATException(
            title: LocalizationService.instance.errorSignUpFailedTitle,
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

  @override
  void initState() {
    uiCampus = LocalizationService.instance.signUpCampuses.split(
      ", ",
    )[selectedCampusIndex];

    requestCampus = LocalizationService.instance.signUpRequestCampuses.split(
      ", ",
    )[selectedCampusIndex];

    uiCollge = LocalizationService.instance.signUpColleges.split(
      ", ",
    )[selectedCollegeIndex];

    requestCollege = LocalizationService.instance.signUpRequestColleges.split(
      ", ",
    )[selectedCollegeIndex];

    uiDepartments = LocalizationService.instance
        .signUpDepartments(uiCollge)
        .split(", ")[selectedDepartmentIndex];

    requestDepartment = LocalizationService.instance
        .signUpRequestDepartments(uiCollge)
        .split(", ")[selectedDepartmentIndex];

    campusCollegeDepartments = [
      SizedBox(width: 6.w),
      Text(uiCampus, style: AppTextTheme.caption1),
      Text(uiCollge, style: AppTextTheme.caption1),
      Text(uiDepartments, style: AppTextTheme.caption1),
      SizedBox(width: 6.w),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        FocusManager.instance.primaryFocus?.unfocus();

        if (_nameSectionFormKey.currentState!.validate()) {
          setIsNameValidated(true);
        } else {
          setIsNameValidated(false);
        }

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
            LocalizationService.instance.signUpFillInform,
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
              SliverToBoxAdapter(child: SizedBox(height: 10.w)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 15.w,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) =>
                        campusCollegeDepartments[index],
                    separatorBuilder: (context, index) => SizedBox(width: 10.w),
                    itemCount: campusCollegeDepartments.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10.w)),
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
                        Form(
                          key: _nameSectionFormKey,
                          child: SignUpNameTextField(
                            nameController: nameController,
                            flagController: setIsNameValidated,
                          ),
                        ),
                        SizedBox(height: 30.w),
                        NicknameSection(
                          controller: nicknameController,
                          flagController: setIsNicknameValidated,
                        ),
                        SizedBox(height: 30.w),
                        SIDSection(
                          controller: studentIdController,
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
                        SizedBox(height: 30.w),
                        SignSection(flagController: setSignatureBase64),
                        SizedBox(height: 30.w),
                        TermsOfAgreement(flagController: setIsAgreementChecked),
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
          onTap:
              (_isNameValidated &&
                  _isNicknameValidated &&
                  _isStudentIdValidated &&
                  _isPasswordValidated &&
                  _signatureBase64 != null &&
                  _isAgreementChecked)
              ? signUp
              : () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.5.w, color: AppColors.common300),
              ),
            ),
            child: BottomAppBar(
              color:
                  (_isNameValidated &&
                      _isNicknameValidated &&
                      _isStudentIdValidated &&
                      _isPasswordValidated &&
                      _signatureBase64 != null &&
                      _isAgreementChecked)
                  ? AppColors.primary
                  : AppColors.common200,
              height: 56.w,
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: AutoSizeText(
                    LocalizationService.instance.signUpSignUp,
                    style:
                        (_isNameValidated &&
                            _isNicknameValidated &&
                            _isStudentIdValidated &&
                            _isPasswordValidated &&
                            _signatureBase64 != null &&
                            _isAgreementChecked)
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
