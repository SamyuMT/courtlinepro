import 'package:get/get.dart';
import '../controllers/robot_config_controller.dart';

class RobotConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RobotConfigController>(() => RobotConfigController());
  }
}
