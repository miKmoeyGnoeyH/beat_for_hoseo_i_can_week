import 'package:beat/shared/theme/index.dart';
import 'package:flutter/material.dart';

class BEATCircularProgressIndicator extends StatelessWidget {
  const BEATCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
