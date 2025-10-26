import 'package:get/get.dart';
import '../controllers/bluetooth_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // SOLO el controlador Bluetooth debe ser permanente para mantener la conexión
    // Todos los demás controladores deben reiniciarse en cada página
    Get.put<BluetoothController>(BluetoothController(), permanent: true);
  }
}
