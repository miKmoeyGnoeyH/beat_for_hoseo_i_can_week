import 'package:beat/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BEATShadowContainer extends StatelessWidget {
  const BEATShadowContainer({
    super.key,
    this.borderRadius = 15,
    this.shadowBlurRadius = 0,
    this.shadowSpreadRadius = 0,
    this.shadowOffset = Offset.zero,
    this.contentPadding = EdgeInsets.zero,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.commonWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.common400,
            blurRadius: shadowBlurRadius,
            spreadRadius: shadowSpreadRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: Padding(padding: contentPadding, child: child),
    );
  }

  final double borderRadius;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final Offset shadowOffset;
  final EdgeInsetsGeometry contentPadding;
  final Widget? child;
}
