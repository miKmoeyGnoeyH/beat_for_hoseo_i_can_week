import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class ProfileCardContentOnLoading extends StatelessWidget {
  const ProfileCardContentOnLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              LocalizationService.instance.profileName,
              style: AppTextTheme.body2,
            ),
            Text("Loading", style: AppTextTheme.body2),
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
            Text("Loading", style: AppTextTheme.body2),
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
            Text("Loading", style: AppTextTheme.body2),
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
            Text("Loading", style: AppTextTheme.body2),
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
            Text("Loading", style: AppTextTheme.body2),
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
            Text("Loading", style: AppTextTheme.body2),
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
            Text("Loading", style: AppTextTheme.body2),
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
            Text("Loading", style: AppTextTheme.body2),
          ],
        ),
      ],
    );
  }
}
