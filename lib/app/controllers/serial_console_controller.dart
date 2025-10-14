import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bluetooth_controller.dart';

class SerialConsoleController extends GetxController {
  late BluetoothController bluetoothController;

  // Mensajes del console
  var consoleMessages = <String>[].obs;
  var inputText = ''.obs;

  // Estado de conexión
  var isConnected = false.obs;

  // Controller para el TextField
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    try {
      bluetoothController = Get.find<BluetoothController>();
      _setupConsole();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo conectar con el controlador Bluetooth',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Configurar listener de conexión
    ever(bluetoothController.isConnected, (connected) {
      isConnected.value = connected;
      if (connected) {
        addMessage(
          "Sistema: Conectado al robot - Listo para comandos",
          isSystem: true,
        );
        bluetoothController.setDataListener(onDataReceived);
      } else {
        addMessage("Sistema: Desconectado del robot", isSystem: true);
      }
    });

    // Inicializar estado de conexión
    isConnected.value = bluetoothController.isConnected.value;
    if (isConnected.value) {
      bluetoothController.setDataListener(onDataReceived);
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _setupConsole() {
    addMessage("=== SERIAL CONSOLE DEBUG ===", isSystem: true);
    addMessage("Conecta al robot y observa la comunicación", isSystem: true);
    addMessage("Escribe comandos y presiona Enter para enviar", isSystem: true);
    addMessage("", isSystem: true);
  }

  // Agregar mensaje al console
  void addMessage(
    String message, {
    bool isSystem = false,
    bool isSent = false,
  }) {
    String timestamp = DateTime.now().toString().substring(11, 19);
    String prefix;

    if (isSystem) {
      prefix = "[$timestamp] SYS: ";
    } else if (isSent) {
      prefix = "[$timestamp] >>> ";
    } else {
      prefix = "[$timestamp] <<< ";
    }

    consoleMessages.add("$prefix$message");

    // Mantener máximo 100 mensajes
    if (consoleMessages.length > 100) {
      consoleMessages.removeAt(0);
    }

    // Auto-scroll al final
    Timer(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Recibir datos del BLE
  void onDataReceived(String data) {
    addMessage(data.trim());
  }

  // Enviar comando
  Future<void> sendCommand(String command) async {
    if (!isConnected.value) {
      addMessage("Error: Robot no conectado", isSystem: true);
      return;
    }

    if (command.isEmpty) return;

    try {
      // Mostrar comando enviado
      addMessage(command, isSent: true);

      // Enviar al robot
      await bluetoothController.sendData(command);

      // Limpiar input
      textController.clear();
      inputText.value = '';
    } catch (e) {
      addMessage("Error enviando comando: $e", isSystem: true);
    }
  }

  // Limpiar console
  void clearConsole() {
    consoleMessages.clear();
    addMessage("Console limpiado", isSystem: true);
  }

  // Comandos predefinidos del robot
  void sendPredefinedCommand(String command) {
    sendCommand(command);
  }

  // Navegar a tests
  void navigateToTests() {
    Get.toNamed('/pruebasrobot');
  }

  // Navegar a configuración
  void navigateToConfiguration() {
    Get.toNamed('/configuracionrobot');
  }

  // Obtener información de debug
  String getDebugInfo() {
    return bluetoothController.getConnectionDebugInfo();
  }
}
