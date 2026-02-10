import 'package:get/get.dart';
import 'package:beat/pages/index.dart';

part 'app_routes.dart';

abstract class BEATPages {
  static final pages = [
    GetPage(name: BEATRoute.splash, page: () => Splash()),
    GetPage(name: BEATRoute.signIn, page: () => SignIn()),
    GetPage(
      name: BEATRoute.affiliation,
      page: () => Affiliation(),
      binding: RegisterBinding(),
      children: [
        GetPage(
          name: BEATRoute.college,
          page: () => College(),
          children: [
            GetPage(
              name: BEATRoute.department,
              page: () => Department(),
              children: [
                GetPage(name: BEATRoute.fillInform, page: () => FillInform()),
              ],
            ),
          ],
        ),
      ],
    ),
    GetPage(name: BEATRoute.home, page: () => Home(), binding: HomeBinding()),
  ];
}
