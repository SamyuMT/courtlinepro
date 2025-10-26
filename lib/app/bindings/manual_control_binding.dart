import 'package:get/get.dart';
import '../controllers/manual_control_controller.dart';

class ManualControlBinding extends Bindings {
  @override
  void dependencies() {
    // Forzar creación nueva cada vez que se entra a la página
    Get.delete<ManualControlController>();
    Get.put<ManualControlController>(ManualControlController());
  }
}
