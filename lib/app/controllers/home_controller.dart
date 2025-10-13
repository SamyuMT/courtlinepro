import 'package:get/get.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Inicialización del controlador
  }

  @override
  void onReady() {
    super.onReady();
    // Cuando el controlador está listo
  }

  @override
  void onClose() {
    super.onClose();
    // Limpieza cuando se cierra el controlador
  }

  // Navegar a la página de conexión Bluetooth
  void navigateToBluetoothConnection() {
    Get.toNamed('/conexionbt');
  }
}
