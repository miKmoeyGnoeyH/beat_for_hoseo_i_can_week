import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';

import '../../shared/index.dart';

class SignSection extends StatefulWidget {
  const SignSection({super.key, required this.flagController});

  @override
  State<SignSection> createState() => _SignSectionState();

  final void Function(String?) flagController;
}

class _SignSectionState extends State<SignSection> {
  final HandSignatureControl handSignatureControl = HandSignatureControl(
    initialSetup: const SignaturePathSetup(
      threshold: 5.0,
      smoothRatio: 1,
      velocityRange: 2.0,
    ),
  );

  String? signatureBase64;

  Future<void> openBottomSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  LocalizationService.instance.signUpSign,
                  style: AppTextTheme.subtitle3,
                ),
                SizedBox(height: 16.w),
                Stack(
                  children: [
                    Positioned(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5.w,
                              color: AppColors.common300,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: HandSignature(control: handSignatureControl),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 1.w,
                      right: 1.w,
                      child: IconButton(
                        onPressed: handSignatureControl.clear,
                        icon: Icon(Icons.refresh, color: AppColors.common300),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.w),
                BEATTextButton(
                  text: LocalizationService.instance.generalConfirm,
                  onTap: () async {
                    await onSignDone();
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onSignDone() async {
    if (!handSignatureControl.isFilled) {
      signatureBase64 = null;
      widget.flagController(null);
      return;
    }

    ByteData? signature = await handSignatureControl.toImage(
      background: Colors.transparent,
      width: 800,
      height: 450,
      fit: true,
    );

    if (signature == null) {
      throw Exception();
    }

    signatureBase64 = base64Encode(signature.buffer.asUint8List());
    widget.flagController(signatureBase64);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.instance.signUpSign,
          style: AppTextTheme.subtitle3,
        ),
        SizedBox(height: 16.w),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: openBottomSheet,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(width: 0.5.w, color: AppColors.common300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: handSignatureControl.isFilled
                  ? Image.memory(
                      alignment: Alignment.center,
                      base64Decode(signatureBase64!),
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        LocalizationService.instance.signUpTapSignButton,
                        style: AppTextTheme.body1.common300,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 16.w),
        Text(
          LocalizationService.instance.signUpSignInfo,
          style: AppTextTheme.subtitle3,
        ),
        SizedBox(height: 5.w),
        Text(
          LocalizationService.instance.signUpSignInfoContent,
          style: AppTextTheme.body2.common500,
        ),
      ],
    );
  }
}
