import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../logic/robot_config_logic.dart';
import 'bluetooth_controller.dart';

class RobotConfigController extends GetxController {
  // Obtener el controlador de Bluetooth
  late BluetoothController bluetoothController;

  // Velocidades configurables
  var linearVelocity = 10.00.obs;
  var angularVelocity = 0.20.obs;

  // Límites de velocidad
  static const double minLinearVelocity = 9.0;
  static const double maxLinearVelocity = 30.0;
  static const double minAngularVelocity = 0.1;
  static const double maxAngularVelocity = 9.0;

  // Estados
  var isTestingChanges = false.obs;
  var configurationSaved = false.obs;

  // Controllers para TextFields
  final TextEditingController linearVelocityController =
      TextEditingController();
  final TextEditingController angularVelocityController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    try {
      bluetoothController = Get.find<BluetoothController>();
      _loadSavedConfiguration();
    } catch (e) {
      Get.snackbar(
        'Initialization error',
        'Could not load Bluetooth driver',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mensajes recibidos del BLE para monitoreo
  var instructionMessages = <String>[].obs;
  var currentInstruction = "Connecting to the configuration system...".obs;

  @override
  void onReady() {
    super.onReady();

    // REINICIAR la página cada vez que se entra (fresh start)
    instructionMessages.clear();
    instructionMessages.add("=== SETTINGS PAGE STARTED ===");

    // Verificar conexión BLE real (no solo el observable)
    _verifyAndInitializeBleConnection();
  }

  // Verificar el estado real de la conexión BLE
  void _verifyAndInitializeBleConnection() {
    instructionMessages.add("Checking BLE connection...");

    // Debug completo del estado
    bool isConnectedValue = bluetoothController.isConnected.value;
    bool hasDevice = bluetoothController.connectedDevice != null;
    bool hasWriteChar = bluetoothController.writeCharacteristic != null;

    instructionMessages.add("isConnected.value: $isConnectedValue");
    instructionMessages.add(
      "connectedDevice: ${hasDevice ? 'EXISTS' : 'NULL'}",
    );
    instructionMessages.add(
      "writeCharacteristic: ${hasWriteChar ? 'EXISTS' : 'NULL'}",
    );

    // Si hay dispositivo conectado pero isConnected es false, forzar reconexión del estado
    if (hasDevice && hasWriteChar && !isConnectedValue) {
      instructionMessages.add(
        "DETECTED: Device connected but status inconsistent",
      );
      instructionMessages.add("Forcing status update...");

      // Forzar actualización del estado
      bluetoothController.isConnected.value = true;
      isConnectedValue = true;
    }

    if (isConnectedValue && hasDevice && hasWriteChar) {
      instructionMessages.add(
        "✅ BLE connection verified - Starting setup",
      );
      bluetoothController.setDataListener(onBleDataReceived);
      _startAutomaticConfigurationMode();
    } else {
      instructionMessages.add("❌ No valid BLE connection");
      currentInstruction.value = "No Bluetooth connection. Connect first.";

      // Mostrar debug detallado
      checkConnectionStatus();
    }
  }

  @override
  void onClose() {
    linearVelocityController.dispose();
    angularVelocityController.dispose();
    super.onClose();
  }

  // Iniciar configuración automática (ya verificada la conexión BLE)
  Future<void> _startAutomaticConfigurationMode() async {
    instructionMessages.add("🔧 SENDING COMMAND 'C' FOR CONFIGURATION...");
    currentInstruction.value = "Starting automatic configuration...";

    try {
      // Enviar 'c' automáticamente para entrar al modo configuración
      await bluetoothController.sendData("c");

      instructionMessages.add("✅ Command 'c' sent successfully");
      currentInstruction.value =
          "Configuration mode activated - Ready for speeds";

      print('✅ Automatic configuration started successfully');
    } catch (e) {
      instructionMessages.add("❌ Error sending 'c': $e");
      currentInstruction.value = "Error starting configuration";

      print('❌ Configuration error: $e');

      // Mostrar snackbar de error
      Get.snackbar(
        'Error BLE',
        'Failed to send configuration command: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // Recibir datos del BLE
  void onBleDataReceived(String data) {
    // Limpiar el string recibido
    String cleanData = data.trim();
    if (cleanData.isEmpty) return;

    // Agregar mensaje recibido a las instrucciones
    instructionMessages.add(cleanData);
    currentInstruction.value = cleanData;

    // Mantener máximo 8 mensajes en historial (widget más pequeño)
    if (instructionMessages.length > 8) {
      instructionMessages.removeAt(0);
    }
  }

  // Cargar configuración guardada
  void _loadSavedConfiguration() {
    // Aquí se puede cargar la configuración desde SharedPreferences
    // Por ahora usamos valores por defecto
    linearVelocity.value = 10.00;
    angularVelocity.value = 0.4;

    // Inicializar controllers de TextField
    linearVelocityController.text = linearVelocity.value.toStringAsFixed(2);
    angularVelocityController.text = angularVelocity.value.toStringAsFixed(2);
  }

  // Actualizar velocidad lineal
  void updateLinearVelocity(double newValue) {
    if (newValue >= minLinearVelocity && newValue <= maxLinearVelocity) {
      linearVelocity.value = double.parse(newValue.toStringAsFixed(2));
      // Sincronizar con TextField
      linearVelocityController.text = linearVelocity.value.toStringAsFixed(2);
      configurationSaved.value = false;
      // NO enviar automáticamente, solo cuando se confirme
    } else {
      Get.snackbar(
        'Invalid value',
        'The linear velocity must be between $minLinearVelocity y $maxLinearVelocity cm/s',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Restaurar valor anterior en TextField
      linearVelocityController.text = linearVelocity.value.toStringAsFixed(2);
    }
  }

  // Actualizar velocidad angular
  void updateAngularVelocity(double newValue) {
    if (newValue >= minAngularVelocity && newValue <= maxAngularVelocity) {
      angularVelocity.value = double.parse(newValue.toStringAsFixed(2));
      // Sincronizar con TextField
      angularVelocityController.text = angularVelocity.value.toStringAsFixed(2);
      configurationSaved.value = false;
      // NO enviar automáticamente, solo cuando se confirme
    } else {
      Get.snackbar(
        'Invalid value',
        'The angular velocity must be between $minAngularVelocity y $maxAngularVelocity rad/s',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Restaurar valor anterior en TextField
      angularVelocityController.text = angularVelocity.value.toStringAsFixed(2);
    }
  }

  // Confirmar velocidades - Envía 'vl,va' y luego 'n'
  Future<void> confirmVelocities() async {
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Offline',
        'No Bluetooth connection to confirm speeds',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Convertir velocidad lineal de cm/s a m/s
      double linearVelocityMS = linearVelocity.value / 100;

      // Crear comando en formato 'vl,va'
      String velocityCommand =
          '${linearVelocityMS.toStringAsFixed(2)},${angularVelocity.value.toStringAsFixed(2)}';

      instructionMessages.add("Sending speeds: $velocityCommand");
      currentInstruction.value = "Setting speeds...";

      // Enviar velocidades
      await bluetoothController.sendData(velocityCommand);

      instructionMessages.add("Sent speeds, confirming...");

      // Esperar 1 segundo y enviar 'n' para confirmar
      await Future.delayed(const Duration(seconds: 1));

      await bluetoothController.sendData("n");

      instructionMessages.add("Command 'n' sent - configuration confirmed");
      currentInstruction.value = "Speeds successfully set";

      configurationSaved.value = true;

      Get.snackbar(
        'Configured speeds',
        'Speeds have been sent and confirmed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      instructionMessages.add("Error confirming speeds: $e");
      Get.snackbar(
        'Error',
        'Error confirming speeds: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Probar cambios - Va a test, comportamiento depende del origen
  Future<void> testChanges() async {
    if (!configurationSaved.value) {
      Get.snackbar(
        'Unsaved configuration',
        'Confirm speeds before testing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Ir a la página de tests con flag indicando que viene de configuración
    Get.toNamed(
      '/pruebasrobot',
      arguments: {
        'comeFromConfig': true, // Indica que viene de configuración
        'autoNavigateToDriving': true, // Debe ir automáticamente a driving
      },
    );
  }

  // Resetear a valores por defecto
  void resetToDefaults() {
    linearVelocity.value = 10.22;
    angularVelocity.value = 10.22;
    configurationSaved.value = false;

    Get.snackbar(
      'Settings reset',
      'The values have been reset to default values',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Guardar configuración
  Future<void> saveConfiguration() async {
    try {
      // Aquí se puede guardar en SharedPreferences
      configurationSaved.value = true;

      Get.snackbar(
        'Configuration saved',
        'The configuration has been saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error saving configuration: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navegar a control manual
  void navigateToManualControl() {
    if (!configurationSaved.value) {
      Get.snackbar(
        'Unsaved configuration',
        'Save the settings before continuing',
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

  // Obtener información de debug de la conexión BLE
  String getConnectionDebugInfo() {
    return bluetoothController.getConnectionDebugInfo();
  }

  // Método para verificar y mostrar estado de la conexión
  void checkConnectionStatus() {
    instructionMessages.add("=== DEBUG INFO ===");
    instructionMessages.add(
      "BLE Connected: ${bluetoothController.isConnected.value}",
    );
    instructionMessages.add(
      "Device: ${bluetoothController.connectedDevice?.platformName ?? 'None'}",
    );
    instructionMessages.add(
      "Write Char: ${bluetoothController.writeCharacteristic != null ? 'Available' : 'NULL'}",
    );
    instructionMessages.add(
      "Notify Char: ${bluetoothController.notifyCharacteristic != null ? 'Available' : 'NULL'}",
    );
  }

  // Método público para iniciar configuración manualmente
  void startConfiguration() {
    _startAutomaticConfigurationMode();
  }
}
