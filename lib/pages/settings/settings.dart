import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../shared/index.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        child: NestedScrollView(
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BEATSliverBackAppBar(
                title: LocalizationService.instance.settingsSettings,
              ),
            ];
          },
          body: Column(),
        ),
      ),
    );
  }
}
