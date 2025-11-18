import 'package:beat/shared/extensions/index.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:beat/shared/widgets/beat_text_button.dart';
import 'package:beat/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonWidgets extends StatelessWidget {
  const CommonWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            BEATSliverAppBar(title: "김현겸"),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BEATInterestCard(label: "point", content: "1,234"),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BeatListItem(
                  label: "Quest 01",
                  title: "BEATListItem",
                  description: "description",
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BEATTextButton(text: "abab",),
              ),
            )
          ],
        ),
      ),
    );
  }
}
