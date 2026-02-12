import 'package:get/get.dart';
import 'package:beat/pages/index.dart';

part 'app_routes.dart';

abstract class BEATPages {
  static final pages = [
    GetPage(name: BEATRoute.splash, page: () => Splash()),
    GetPage(name: BEATRoute.signIn, page: () => SignIn()),
    GetPage(name: BEATRoute.campus, page: () => Campus()),
    GetPage(name: BEATRoute.college, page: () => College()),
    GetPage(name: BEATRoute.department, page: () => Department()),
    GetPage(name: BEATRoute.fillInform, page: () => FillInform()),
    GetPage(name: BEATRoute.mainPageView, page: () => MainPageView(), binding: MainPageViewBinding()),
    GetPage(name: BEATRoute.pointHistory, page: () => PointHistory(), binding: PointHistoryBinding()),
    GetPage(name: BEATRoute.noticeList, page: () => NoticeList(), binding: NoticeListBinding()),
    GetPage(name: BEATRoute.questDetail, page: () => QuestDetail()),
    GetPage(name: BEATRoute.teamManagement, page: () => TeamManagement(), binding: TeamManagementBinding()),
  ];
}
