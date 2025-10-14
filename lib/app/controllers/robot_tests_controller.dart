import 'dart:async';
import 'package:get/get.dart';
import 'bluetooth_controller.dart';

class RobotTestsController extends GetxController {
  // Obtener el controlador de Bluetooth
  late BluetoothController bluetoothController;

  // Estados de las pruebas de movimiento
  var movementTests = {
    'forward': false.obs,
    'reverse': false.obs,
    'right': false.obs,
    'left': false.obs,
    'rotation': false.obs,
  };

  // Estados de las pruebas de solenoide
  var solenoidTests = {'off': false.obs, 'on': false.obs, 'motion': false.obs};

  // Estado general
  var allTestsCompleted = false.obs;
  var currentlyTesting = ''.obs;

  // Mensajes recibidos del BLE para mostrar en instrucciones
  var instructionMessages = <String>[].obs;
  var currentInstruction = "Conectando al robot...".obs;

  // Control para enviar comando solo una vez
  var testInitiated = false.obs;
  var robotReady = false.obs; // Si el robot mostró su menú y está listo

  // Subscription para recibir datos del BLE
  StreamSubscription? _dataSubscription;

  @override
  void onInit() {
    super.onInit();
    try {
      bluetoothController = Get.find<BluetoothController>();
      _setupTestsListener();
      _setupBleDataListener();
    } catch (e) {
      Get.snackbar(
        'Error de inicialización',
        'No se pudo inicializar el controlador de tests',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Solo configurar listener, NO enviar "t" automáticamente
    _waitForRobotMenu();
  }

  @override
  void onClose() {
    super.onClose();
    _dataSubscription?.cancel();
  }

  // Configurar listener para verificar si todas las pruebas están completas
  void _setupTestsListener() {
    ever(movementTests['forward']!, _checkAllTestsCompleted);
    ever(movementTests['reverse']!, _checkAllTestsCompleted);
    ever(movementTests['right']!, _checkAllTestsCompleted);
    ever(movementTests['left']!, _checkAllTestsCompleted);
    ever(movementTests['rotation']!, _checkAllTestsCompleted);
    ever(solenoidTests['off']!, _checkAllTestsCompleted);
    ever(solenoidTests['on']!, _checkAllTestsCompleted);
    ever(solenoidTests['motion']!, _checkAllTestsCompleted);
  }

  // Configurar listener para recibir datos del BLE
  void _setupBleDataListener() {
    if (bluetoothController.isConnected.value) {
      // Configurar listener para recibir datos del BLE
      bluetoothController.setDataListener(onBleDataReceived);
      print('Listener de BLE configurado');
    } else {
      print('No hay conexión BLE activa');
    }
  }

  // Esperar a que el robot muestre su menú principal
  void _waitForRobotMenu() {
    if (!bluetoothController.isConnected.value) {
      currentInstruction.value = "Sin conexión Bluetooth. Conéctate primero.";
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth activa',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Configurar el listener de BLE
    _setupBleDataListener();
    currentInstruction.value = "Esperando que el robot muestre su menú...";

    // Solo simular si no hay conexión real
    if (!bluetoothController.isConnected.value) {
      _simulateRobotMenu();
    }
  }

  // Iniciar test automático enviando "t" - SOLO cuando el robot esté listo
  Future<void> _initiateAutomaticTest() async {
    if (testInitiated.value) {
      return; // Ya se inició el test
    }

    if (!robotReady.value) {
      Get.snackbar(
        'Robot no listo',
        'Espera a que el robot muestre su menú principal',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Enviar comando "t" para iniciar test automático
      await bluetoothController.sendData("t");
      testInitiated.value = true;
      currentInstruction.value = "Comando 't' enviado - iniciando tests...";

      Get.snackbar(
        'Test iniciado',
        'Se envió comando de inicio de test al robot',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al iniciar test automático: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Simular el menú del robot (solo para testing sin conexión)
  void _simulateRobotMenu() {
    Timer(const Duration(seconds: 2), () {
      instructionMessages.add("=== ROBOT CONTROL SYSTEM ===");
      instructionMessages.add("c - Configuration Mode");
      instructionMessages.add("t - Test Mode");
      instructionMessages.add("r - Remote Control Mode");
      instructionMessages.add("s - Activate Relay/Solenoid");
      instructionMessages.add("Select option:");

      currentInstruction.value =
          "Robot listo - Presiona 'Iniciar Test' para enviar 't'";
      robotReady.value = true;

      // Mantener máximo 10 mensajes
      if (instructionMessages.length > 10) {
        instructionMessages.removeRange(0, instructionMessages.length - 10);
      }
    });
  }

  // Verificar si todas las pruebas están completas
  void _checkAllTestsCompleted(bool _) {
    bool movementComplete = movementTests.values.every((test) => test.value);
    bool solenoidComplete = solenoidTests.values.every((test) => test.value);

    allTestsCompleted.value = movementComplete && solenoidComplete;
  }

  // Confirmar test visualmente (solo checklist, no envía comandos)
  void confirmTest(String testType) {
    // Solo marcar como completado para el checklist visual
    _markTestCompleted(testType);

    // Solo mostrar notificación si se completaron todos los tests
    if (allTestsCompleted.value) {
      Get.snackbar(
        'Todos los tests completados',
        'Puedes continuar a la configuración del robot',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    }
  }

  // Marcar una prueba como completada
  void _markTestCompleted(String testType) {
    switch (testType) {
      case 'forward':
        movementTests['forward']!.value = true;
        break;
      case 'reverse':
        movementTests['reverse']!.value = true;
        break;
      case 'right':
        movementTests['right']!.value = true;
        break;
      case 'left':
        movementTests['left']!.value = true;
        break;
      case 'rotation':
        movementTests['rotation']!.value = true;
        break;
      case 'solenoid_off':
        solenoidTests['off']!.value = true;
        break;
      case 'solenoid_on':
        solenoidTests['on']!.value = true;
        break;
      case 'solenoid_motion':
        solenoidTests['motion']!.value = true;
        break;
    }
  }

  // Reiniciar todas las pruebas
  void restartTests() {
    // Resetear estados de movimiento
    movementTests.forEach((key, value) {
      value.value = false;
    });

    // Resetear estados de solenoide
    solenoidTests.forEach((key, value) {
      value.value = false;
    });

    allTestsCompleted.value = false;
    currentlyTesting.value = '';
    testInitiated.value = false;
    instructionMessages.clear();
    currentInstruction.value = "Reiniciando tests...";

    // Reiniciar test automático
    _initiateAutomaticTest();
  }

  // Navegar a configuración del robot
  void navigateToConfiguration() {
    Get.toNamed('/configuracionrobot');
  }

  // Limpiar historial de mensajes
  void clearMessageHistory() {
    instructionMessages.clear();
    currentInstruction.value =
        "Historial limpio - esperando nuevos mensajes...";
  }

  // Método para recibir datos del BLE (llamar desde el BluetoothController)
  void onBleDataReceived(String data) {
    // Limpiar el string recibido
    String cleanData = data.trim();
    if (cleanData.isEmpty) return;

    // Agregar mensaje recibido a las instrucciones
    instructionMessages.add(cleanData);
    currentInstruction.value = cleanData;

    // Mantener máximo 10 mensajes en historial
    if (instructionMessages.length > 10) {
      instructionMessages.removeAt(0);
    }

    // Parsear datos para actualizar estado automáticamente si es necesario
    _parseReceivedData(cleanData);
  }

  // Parsear datos recibidos para determinar el estado del test
  void _parseReceivedData(String data) {
    String lowerData = data.toLowerCase();

    // Detectar cuando el robot muestra su menú principal
    if (lowerData.contains('robot control system') ||
        lowerData.contains('select option') ||
        (lowerData.contains('test mode') &&
            lowerData.contains('configuration'))) {
      robotReady.value = true;
      currentInstruction.value =
          "Robot listo - Presiona 'Iniciar Test' para enviar 't'";
      print('Robot menú detectado - Robot listo para recibir comandos');
    }

    // Detectar mensajes de test en progreso
    if (lowerData.contains('forward movement') ||
        lowerData.contains('reverse movement') ||
        lowerData.contains('right turn') ||
        lowerData.contains('left turn') ||
        lowerData.contains('rotation') ||
        lowerData.contains('solenoid')) {
      // Los tests están ejecutándose
      print('Test en progreso: $data');
    }
  }

  // Método público para iniciar test manualmente
  void startTest() {
    _initiateAutomaticTest();
  }
}
