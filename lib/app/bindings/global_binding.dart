import 'package:get/get.dart';
import '../controllers/bluetooth_controller.dart';
import '../controllers/robot_config_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Controladores globales que siempre están disponibles
    Get.put<BluetoothController>(BluetoothController(), permanent: true);
    Get.put<RobotConfigController>(RobotConfigController(), permanent: true);
  }
}
