import 'package:get/get.dart';
import '../controllers/manual_control_controller.dart';

class ManualControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualControlController>(() => ManualControlController());
  }
}
