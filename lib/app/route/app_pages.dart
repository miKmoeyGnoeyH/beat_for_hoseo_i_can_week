import 'package:beat/pages/init/index.dart';
import 'package:beat/pages/register/index.dart';
import 'package:get/get.dart';
import 'package:beat/pages/index.dart';

part 'app_routes.dart';

abstract class BEATPages {
  static final pages = [
    GetPage(
      name: BEATRoute.init,
      page: () => Init(child: Splash()),
      binding: InitBinding(),
    ),
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
  ];
}
