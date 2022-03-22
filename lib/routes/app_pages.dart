import 'package:get/get.dart';
import 'package:phone_music/screens/home/home_screen.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      transition: Transition.topLevel,
    ),
  ];
}
