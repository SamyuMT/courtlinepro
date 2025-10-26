import 'package:get/get.dart';
import '../controllers/robot_config_controller.dart';

class RobotConfigBinding extends Bindings {
  @override
  void dependencies() {
    // Forzar creación nueva cada vez que se entra a la página
    Get.delete<RobotConfigController>();
    Get.put<RobotConfigController>(RobotConfigController());
  }
}
