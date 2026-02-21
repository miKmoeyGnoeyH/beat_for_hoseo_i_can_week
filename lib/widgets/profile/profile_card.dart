import 'package:beat/features/profile/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/route/index.dart';
import '../../entities/profile/index.dart';
import '../../features/team/index.dart';

class ProfileCard extends StatelessWidget {
  ProfileCard(this.profileModel, {super.key});

  final ProfileController profileController = ProfileController.to;

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return BEATShadowContainer(
      contentPadding: EdgeInsetsGeometry.all(16.w),
      shadowBlurRadius: 30.w,
      shadowSpreadRadius: -17.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.instance.profileMyInfo,
            style: AppTextTheme.subtitle1,
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileName,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.name, style: AppTextTheme.body1),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileStudentId,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.studentId, style: AppTextTheme.body1),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileEmail,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.email, style: AppTextTheme.body1),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileDepartment,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.department, style: AppTextTheme.body1),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileNickname,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.nickname, style: AppTextTheme.body1),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileCampus,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.campus, style: AppTextTheme.body1),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileStudentType,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.studentType.value, style: AppTextTheme.body1),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                LocalizationService.instance.profileTeamName,
                style: AppTextTheme.body1,
              ),
              Text(profileModel.teamName, style: AppTextTheme.body1),
            ],
          ),
          if (profileController.state?.studentType == StudentType.mentor)
            Column(
              children: [
                SizedBox(height: rowSpacing),
                BEATTextButton(
                  text: LocalizationService.instance.profileTeamManagement,
                  onTap: () {
                    TeamBingoStatusController.to.teamId =
                        profileController.state!.teamId;
                    Get.toNamed(BEATRoute.teamManagement);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  final ProfileModel profileModel;
}
