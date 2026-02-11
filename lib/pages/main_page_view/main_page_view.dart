
import 'package:beat/pages/index.dart';
import 'package:beat/shared/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  // PageView 제어를 위한 GetX Controller
  final PageViewController pageViewController = PageViewController.to;

  @override
  void initState() {
    super.initState();
  }

  // TODO: 홈 화면 에러 발생 시 어떻게?
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [MainPageViewAppbar()];
          },
          body: PageView(
            controller: pageViewController.pageController,
            children: [QR(), Home(), Profile()],
          ),
        ),
      ),
      bottomNavigationBar: BEATBNB(),
    );
  }
}
