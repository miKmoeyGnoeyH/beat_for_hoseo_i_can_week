import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PageViewController extends GetxController {
  static PageViewController get to => Get.find<PageViewController>();

  final PageController pageController = PageController(initialPage: 1);

  final List<ScrollController> scrollControllers = List.generate(
    3,
    (_) => ScrollController(),
  );

  final Rx<int> _currentPage = 1.obs;

  int get currentPage => _currentPage.value;

  set _currentPage(int page) => _currentPage.value = page;

  void jumpToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );

    _currentPage = page;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollController = scrollControllers[page];
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void onPageChanged(int page) {
    _currentPage = page;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollController = scrollControllers[page];
      if (!scrollController.hasClients) return;
      scrollController.jumpTo(0);
    });
  }
}
