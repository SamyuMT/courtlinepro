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
        'Error de inicialización',
        'No se pudo cargar el controlador Bluetooth',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mensajes recibidos del BLE para monitoreo
  var instructionMessages = <String>[].obs;
  var currentInstruction = "Conectando al sistema de configuración...".obs;

  @override
  void onReady() {
    super.onReady();

    // REINICIAR la página cada vez que se entra (fresh start)
    instructionMessages.clear();
    instructionMessages.add("=== PÁGINA DE CONFIGURACIÓN INICIADA ===");

    // Verificar conexión BLE real (no solo el observable)
    _verifyAndInitializeBleConnection();
  }

  // Verificar el estado real de la conexión BLE
  void _verifyAndInitializeBleConnection() {
    instructionMessages.add("Verificando conexión BLE...");

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
        "DETECTADO: Dispositivo conectado pero estado inconsistente",
      );
      instructionMessages.add("Forzando actualización del estado...");

      // Forzar actualización del estado
      bluetoothController.isConnected.value = true;
      isConnectedValue = true;
    }

    if (isConnectedValue && hasDevice && hasWriteChar) {
      instructionMessages.add(
        "✅ Conexión BLE verificada - Iniciando configuración",
      );
      bluetoothController.setDataListener(onBleDataReceived);
      _startAutomaticConfigurationMode();
    } else {
      instructionMessages.add("❌ Sin conexión BLE válida");
      currentInstruction.value = "Sin conexión Bluetooth. Conéctate primero.";

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
    instructionMessages.add("🔧 ENVIANDO COMANDO 'C' PARA CONFIGURACIÓN...");
    currentInstruction.value = "Iniciando configuración automática...";

    try {
      // Enviar 'c' automáticamente para entrar al modo configuración
      await bluetoothController.sendData("c");

      instructionMessages.add("✅ Comando 'c' enviado exitosamente");
      currentInstruction.value =
          "Modo configuración activado - Listo para velocidades";

      print('✅ Configuración automática iniciada correctamente');
    } catch (e) {
      instructionMessages.add("❌ Error enviando 'c': $e");
      currentInstruction.value = "Error al iniciar configuración";

      print('❌ Error en configuración: $e');

      // Mostrar snackbar de error
      Get.snackbar(
        'Error BLE',
        'No se pudo enviar comando de configuración: $e',
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
        'Valor inválido',
        'La velocidad lineal debe estar entre $minLinearVelocity y $maxLinearVelocity cm/s',
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
        'Valor inválido',
        'La velocidad angular debe estar entre $minAngularVelocity y $maxAngularVelocity rad/s',
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
        'Sin conexión',
        'No hay conexión Bluetooth para confirmar velocidades',
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

      instructionMessages.add("Enviando velocidades: $velocityCommand");
      currentInstruction.value = "Configurando velocidades...";

      // Enviar velocidades
      await bluetoothController.sendData(velocityCommand);

      instructionMessages.add("Velocidades enviadas, confirmando...");

      // Esperar 1 segundo y enviar 'n' para confirmar
      await Future.delayed(const Duration(seconds: 1));

      await bluetoothController.sendData("n");

      instructionMessages.add("Comando 'n' enviado - configuración confirmada");
      currentInstruction.value = "Velocidades configuradas exitosamente";

      configurationSaved.value = true;

      Get.snackbar(
        'Velocidades configuradas',
        'Las velocidades han sido enviadas y confirmadas',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      instructionMessages.add("Error al confirmar velocidades: $e");
      Get.snackbar(
        'Error',
        'Error al confirmar velocidades: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Probar cambios - Va a test, comportamiento depende del origen
  Future<void> testChanges() async {
    if (!configurationSaved.value) {
      Get.snackbar(
        'Configuración no guardada',
        'Confirma las velocidades antes de probar',
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
