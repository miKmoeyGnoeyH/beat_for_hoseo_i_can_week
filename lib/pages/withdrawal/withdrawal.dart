import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:beat/shared/index.dart';
import 'package:beat/widgets/index.dart';

class Withdrawal extends StatefulWidget {
  const Withdrawal({super.key});

  @override
  State<Withdrawal> createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  bool _isAgreed = false;

  Future<void> withdrawal() async {
    if (!(_isAgreed)) {
      DialogService.to.addDialogEvent(
        AlertDialogEvent(
          title: LocalizationService.instance.withdrawalFailed,
          message: LocalizationService.instance.withdrawalFailedMessage,
        ),
      );
      return;
    }

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 100));
          return await APIService().post(
            endpoint: DotEnvService.instance.withdrawal,
            header: {
              "Content-Type": "application/json",
              "authorization": AuthenticationController.to.state!.authorization,
            },
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      switch (response.statusCode) {
        case 200:
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService.instance.withdrawalSuccess,
              message: LocalizationService.instance.withdrawalSuccessMessage,
              onConfirm: () {
                AuthenticationController.to.SignOut();
                Get.offAllNamed(BEATRoute.signIn);
              },
            ),
          );
          break;
        case 401:
          throw BEATTokenExpired();
        case 400:
          throw BEATException(
            title: LocalizationService.instance.withdrawalFailed,
            message: LocalizationService.instance.withdrawalFailedMessage,
          );
        default:
          throw Exception();
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATTokenExpired catch (e) {
      await AuthenticationController.to.reissueToken();
      withdrawal();
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

  void toggleAgreement(bool? value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isAgreed = value ?? false;
    });
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
      },
      child: Scaffold(
        backgroundColor: AppColors.designWhite,
        appBar: AppBar(
          title: Text(
            LocalizationService.instance.withdrawalAppbarTitle,
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
                        Text(
                          LocalizationService.instance.withdrawalNotes,
                          style: AppTextTheme.subtitle1,
                        ),
                        SizedBox(height: 16.w),
                        Text(
                          "1. ${LocalizationService.instance.withdrawalNote1}",
                          style: AppTextTheme.body2,
                        ),
                        SizedBox(height: 16.w),
                        Text(
                          "2. ${LocalizationService.instance.withdrawalNote2}",
                          style: AppTextTheme.body2,
                        ),
                        SizedBox(height: 16.w),
                        Text(
                          "3. ${LocalizationService.instance.withdrawalNote3}",
                          style: AppTextTheme.body2,
                        ),
                        SizedBox(height: 16.w),
                        Text(
                          "4. ${LocalizationService.instance.withdrawalNote4}",
                          style: AppTextTheme.body2,
                        ),
                        SizedBox(height: 24.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => toggleAgreement(!_isAgreed),
                                child: Text(
                                  LocalizationService.instance.withdrawalIAgree,
                                  style: AppTextTheme.subtitle3,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: _isAgreed,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ),
                              shape: CircleBorder(),
                              activeColor: AppColors.primary,
                              checkColor: AppColors.commonWhite,
                              onChanged: (value) => toggleAgreement(value),
                            ),
                          ],
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
          onTap: (_isAgreed) ? withdrawal : () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.5.w, color: AppColors.common300),
              ),
            ),
            child: BottomAppBar(
              color: (_isAgreed) ? AppColors.primary : AppColors.common200,
              height: 56.w,
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: AutoSizeText(
                    LocalizationService.instance.withdrawalWithdrawal,
                    style: (_isAgreed)
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
