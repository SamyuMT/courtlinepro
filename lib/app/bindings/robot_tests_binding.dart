import 'package:get/get.dart';
import '../controllers/robot_tests_controller.dart';

class RobotTestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RobotTestsController>(() => RobotTestsController());
  }
}
