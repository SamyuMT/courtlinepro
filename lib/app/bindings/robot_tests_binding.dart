import 'package:get/get.dart';
import '../controllers/robot_tests_controller.dart';

class RobotTestsBinding extends Bindings {
  @override
  void dependencies() {
    // Forzar creación nueva cada vez que se entra a la página
    Get.delete<RobotTestsController>();
    Get.put<RobotTestsController>(RobotTestsController());
  }
}
