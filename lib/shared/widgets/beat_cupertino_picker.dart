import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BEATCupertinoPicker extends StatelessWidget {
  const BEATCupertinoPicker({
    super.key,
    required this.items,
    this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: BEATCupertinoPickerBuilder(
          items: items,
          onSelectedItemChanged: onSelectedItemChanged,
        ),
      ),
    );
  }

  final List<dynamic> items;
  final Function(int index)? onSelectedItemChanged;
}

class BEATCupertinoPickerBuilder extends StatelessWidget {
  const BEATCupertinoPickerBuilder({
    super.key,
    required this.items,
    this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MaterialScrollBehavior().copyWith(overscroll: false),
      child: CupertinoPicker.builder(
        itemExtent: 45.w,
        childCount: items.length,
        onSelectedItemChanged: onSelectedItemChanged,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Center(
            child: AutoSizeText(
              items[index].toString(),
              style: AppTextTheme.title1.designBlack,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }

  final List<dynamic> items;
  final Function(int index)? onSelectedItemChanged;
}