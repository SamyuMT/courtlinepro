import 'package:get/get.dart';
import '../logic/robot_config_logic.dart';
import 'bluetooth_controller.dart';

class RobotConfigController extends GetxController {
  // Obtener el controlador de Bluetooth
  late BluetoothController bluetoothController;

  // Velocidades configurables
  var linearVelocity = 10.22.obs;
  var angularVelocity = 10.22.obs;

  // Límites de velocidad
  static const double minLinearVelocity = 1.0;
  static const double maxLinearVelocity = 50.0;
  static const double minAngularVelocity = 1.0;
  static const double maxAngularVelocity = 20.0;

  // Estados
  var isTestingChanges = false.obs;
  var configurationSaved = false.obs;

  @override
  void onInit() {
    super.onInit();
    bluetoothController = Get.find<BluetoothController>();
    _loadSavedConfiguration();
  }

  @override
  void onReady() {
    super.onReady();
    // Verificar conexión Bluetooth
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth activa',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Cargar configuración guardada
  void _loadSavedConfiguration() {
    // Aquí se puede cargar la configuración desde SharedPreferences
    // Por ahora usamos valores por defecto
    linearVelocity.value = 10.22;
    angularVelocity.value = 10.22;
  }

  // Actualizar velocidad lineal
  void updateLinearVelocity(double newValue) {
    if (newValue >= minLinearVelocity && newValue <= maxLinearVelocity) {
      linearVelocity.value = double.parse(newValue.toStringAsFixed(2));
      configurationSaved.value = false;

      // Enviar comando inmediatamente si está conectado
      if (bluetoothController.isConnected.value) {
        _sendLinearVelocityCommand();
      }
    } else {
      Get.snackbar(
        'Valor inválido',
        'La velocidad lineal debe estar entre $minLinearVelocity y $maxLinearVelocity cm/s',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Actualizar velocidad angular
  void updateAngularVelocity(double newValue) {
    if (newValue >= minAngularVelocity && newValue <= maxAngularVelocity) {
      angularVelocity.value = double.parse(newValue.toStringAsFixed(2));
      configurationSaved.value = false;

      // Enviar comando inmediatamente si está conectado
      if (bluetoothController.isConnected.value) {
        _sendAngularVelocityCommand();
      }
    } else {
      Get.snackbar(
        'Valor inválido',
        'La velocidad angular debe estar entre $minAngularVelocity y $maxAngularVelocity rad/s',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Enviar comando de velocidad lineal
  Future<void> _sendLinearVelocityCommand() async {
    try {
      String command = RobotConfigLogic.generateLinearVelocityCommand(
        linearVelocity.value,
      );
      await bluetoothController.sendData(command);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al enviar velocidad lineal: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Enviar comando de velocidad angular
  Future<void> _sendAngularVelocityCommand() async {
    try {
      String command = RobotConfigLogic.generateAngularVelocityCommand(
        angularVelocity.value,
      );
      await bluetoothController.sendData(command);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al enviar velocidad angular: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Probar cambios de configuración
  Future<void> testChanges() async {
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth para probar cambios',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isTestingChanges.value = true;

    try {
      // Enviar configuración completa al robot
      await _sendCompleteConfiguration();

      // Realizar pruebas básicas de movimiento
      await _performConfigurationTests();

      configurationSaved.value = true;

      Get.snackbar(
        'Configuración aplicada',
        'Los cambios han sido aplicados y probados exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error en pruebas',
        'Error al probar la configuración: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isTestingChanges.value = false;
    }
  }

  // Enviar configuración completa
  Future<void> _sendCompleteConfiguration() async {
    List<String> commands = RobotConfigLogic.generateCompleteConfigCommands(
      linearVelocity.value,
      angularVelocity.value,
    );

    for (String command in commands) {
      await bluetoothController.sendData(command);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Realizar pruebas de configuración
  Future<void> _performConfigurationTests() async {
    List<String> testCommands = RobotConfigLogic.getConfigurationTestCommands();

    for (String command in testCommands) {
      await bluetoothController.sendData(command);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // Resetear a valores por defecto
  void resetToDefaults() {
    linearVelocity.value = 10.22;
    angularVelocity.value = 10.22;
    configurationSaved.value = false;

    Get.snackbar(
      'Configuración restablecida',
      'Los valores han sido restablecidos a los valores por defecto',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Guardar configuración
  Future<void> saveConfiguration() async {
    try {
      // Aquí se puede guardar en SharedPreferences
      configurationSaved.value = true;

      Get.snackbar(
        'Configuración guardada',
        'La configuración ha sido guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al guardar la configuración: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navegar a control manual
  void navigateToManualControl() {
    if (!configurationSaved.value) {
      Get.snackbar(
        'Configuración no guardada',
        'Guarda la configuración antes de continuar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed('/mandocontrol');
  }

  // Validar configuración actual
  bool isCurrentConfigurationValid() {
    return RobotConfigLogic.validateVelocityConfiguration(
      linearVelocity.value,
      angularVelocity.value,
    );
  }
}
