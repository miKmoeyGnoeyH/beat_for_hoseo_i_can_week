import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TermsOfAgreement extends StatefulWidget {
  const TermsOfAgreement({super.key, required this.flagController});

  @override
  State<TermsOfAgreement> createState() => _TermsOfAgreementState();

  final void Function(bool) flagController;
}

class _TermsOfAgreementState extends State<TermsOfAgreement> {
  void openBottomSheet() {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TOABottomSheet(
          isAgreed: _isAgreed,
          toggleAgreement: toggleAgreement,
        );
      },
    );
  }

  void toggleAgreement(bool? value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isAgreed = value ?? false;
      widget.flagController(_isAgreed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5.w, color: AppColors.common300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: openBottomSheet,
              child: Text(
                LocalizationService.instance.signUpTermsOfAgreement,
                style: AppTextTheme.subtitle3,
              ),
            ),
          ),
          Checkbox(
            value: _isAgreed,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            shape: CircleBorder(),
            activeColor: AppColors.primary,
            checkColor: AppColors.commonWhite,
            onChanged: (value) => toggleAgreement(value),
          ),
        ],
      ),
    );
  }

  bool _isAgreed = false;
}

class TOABottomSheet extends StatefulWidget {
  TOABottomSheet({
    super.key,
    required this.isAgreed,
    required this.toggleAgreement,
  });

  @override
  State<TOABottomSheet> createState() => _TOABottomSheetState();

  bool isAgreed;
  final void Function(bool?) toggleAgreement;
}

class _TOABottomSheetState extends State<TOABottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.commonWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.signUpTermsOfAgreement,
              style: AppTextTheme.subtitle3,
            ),
            SizedBox(height: 16.w),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(width: 0.5.w, color: AppColors.common300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "1. ${LocalizationService.instance.signUpToaPurpose}",
                    style: AppTextTheme.subtitle3,
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    LocalizationService.instance.signUpToaPurposeContent,
                    style: AppTextTheme.body2,
                  ),
                  SizedBox(height: 20.w),
                  Text(
                    "2. ${LocalizationService.instance.signUpToaItems}",
                    style: AppTextTheme.subtitle3,
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    LocalizationService.instance.signUpToaItemsContent,
                    style: AppTextTheme.body2,
                  ),
                  SizedBox(height: 20.w),
                  Text(
                    "3. ${LocalizationService.instance.signUpToaRetention}",
                    style: AppTextTheme.subtitle3,
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    LocalizationService.instance.signUpToaRetentionContent,
                    style: AppTextTheme.body2,
                  ),
                  SizedBox(height: 20.w),
                  Text(
                    "4. ${LocalizationService.instance.signUpToaRightToRefusal}",
                    style: AppTextTheme.subtitle3,
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    LocalizationService.instance.signUpToaRightToRefusalContent,
                    style: AppTextTheme.body2,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          widget.isAgreed = !widget.isAgreed;
                          widget.toggleAgreement(widget.isAgreed);
                          Get.back();
                        });
                      },
                      child: Text(
                        LocalizationService.instance.signUpIAgree,
                        style: AppTextTheme.subtitle3,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: widget.isAgreed,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    shape: CircleBorder(),
                    activeColor: AppColors.primary,
                    checkColor: AppColors.commonWhite,
                    onChanged: (value) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        widget.isAgreed = value ?? false;
                        widget.toggleAgreement(value);
                        Get.back();
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.w),
          ],
        ),
      ),
    );
  }
}
