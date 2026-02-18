import 'package:beat/features/profile/index.dart';
import 'package:beat/widgets/profile/profile_card_content_on_empty.dart';
import 'package:beat/widgets/profile/profile_card_content_on_loading.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/route/index.dart';
import '../../entities/profile/index.dart';
import '../../features/team/index.dart';
import 'profile_card_content_on_error.dart';

class ProfileCard extends StatelessWidget {
  ProfileCard({super.key});

  final ProfileController profileController = ProfileController.to;

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return BEATShadowContainer(
      contentPadding: EdgeInsetsGeometry.all(16.w),
      shadowBlurRadius: 30.w,
      shadowSpreadRadius: -17.w,
      child: profileController.obx(
        (state) {
          return Column(
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state!.name, style: AppTextTheme.body2),
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state.studentId, style: AppTextTheme.body2),
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state.email, style: AppTextTheme.body2),
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state.department, style: AppTextTheme.body2),
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state.nickname, style: AppTextTheme.body2),
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state.campus, style: AppTextTheme.body2),
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state.studentType.value, style: AppTextTheme.body2),
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
                    style: AppTextTheme.body2,
                  ),
                  Text(state.teamName, style: AppTextTheme.body2),
                ],
              ),
              if (profileController.state?.studentType == StudentType.mentee)
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
          );
        },
        onEmpty: ProfileCardContentOnEmpty(),
        onLoading: ProfileCardContentOnLoading(),
        onError: (state) {
          return ProfileCardContentOnError();
        },
      ),
    );
  }
}
