import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PageViewController extends GetxController {
  static PageViewController get to => Get.find<PageViewController>();

  final PageController pageController = PageController(initialPage: 1);
  final Rx<int> _currentPage = 1.obs;

  int get currentPage => _currentPage.value;
  set _currentPage(int page) => _currentPage.value = page;

  void jumpToPage(int page) {
    pageController.animateToPage(page, duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    _currentPage = page;
  }
}