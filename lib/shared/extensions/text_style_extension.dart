import 'package:beat/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  // TextStyle

  // Primary
  get primary => apply(color: AppColors.primary);

  // Design
  get designWhite => apply(color: AppColors.designWhite);
  get designBlack => apply(color: AppColors.designBlack);

  // Status
  get statusComplete => apply(color: AppColors.statusComplete);
  get statusCompleteBackground => apply(color: AppColors.statusCompleteBackground);
  get statusWarning => apply(color: AppColors.statusWarning);
  get statusWarningBackground => apply(color: AppColors.statusWarningBackground);
  get statusError => apply(color: AppColors.statusError);
  get statusErrorBackground => apply(color: AppColors.statusErrorBackground);

  // Common
  // get commonWhite => apply(color: AppColors.commonWhite);
  // get commonBlack => apply(color: AppColors.commonBlack);
  get common800 => apply(color: AppColors.common800);
  get common500 => apply(color: AppColors.common500);
  get common400 => apply(color: AppColors.common400);
  get common300 => apply(color: AppColors.common300);
  get common200 => apply(color: AppColors.common200);
  get common100 => apply(color: AppColors.common100);

  get disabled => apply(color: AppColors.disabledTextColorLight);
}