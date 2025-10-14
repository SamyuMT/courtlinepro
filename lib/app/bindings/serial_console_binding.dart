import 'package:get/get.dart';
import '../controllers/serial_console_controller.dart';

class SerialConsoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SerialConsoleController>(() => SerialConsoleController());
  }
}
