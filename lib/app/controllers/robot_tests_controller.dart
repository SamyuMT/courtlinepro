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

  // Flags para comportamiento de navegación
  var autoNavigateToDriving = false.obs;
  var comeFromConfig = false.obs;

  // Subscription para recibir datos del BLE
  StreamSubscription? _dataSubscription;

  @override
  void onInit() {
    super.onInit();
    try {
      bluetoothController = Get.find<BluetoothController>();

      // Verificar argumentos de navegación
      final arguments = Get.arguments;
      if (arguments != null) {
        if (arguments['autoNavigateToDriving'] == true) {
          autoNavigateToDriving.value = true;
        }
        if (arguments['comeFromConfig'] == true) {
          comeFromConfig.value = true;
        }
      }

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
    // ENVIAR "t" automáticamente al entrar a la página
    _startAutomaticTest();
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

  // Iniciar test automático al entrar a la página
  Future<void> _startAutomaticTest() async {
    if (!bluetoothController.isConnected.value) {
      currentInstruction.value = "Sin conexión Bluetooth. Conéctate primero.";
      instructionMessages.add("Error: No hay conexión BLE activa");
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth activa',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Configurar el listener de BLE primero
    _setupBleDataListener();

    // Enviar 't' automáticamente
    try {
      instructionMessages.add("Enviando comando 't' para iniciar test...");
      currentInstruction.value = "Iniciando test automático...";

      await bluetoothController.sendData("t");
      testInitiated.value = true;

      instructionMessages.add("Comando 't' enviado - test iniciado");
      currentInstruction.value =
          "Test en progreso - observa los movimientos del robot";

      print('Test automático iniciado correctamente');
    } catch (e) {
      instructionMessages.add("Error al enviar comando 't': $e");
      currentInstruction.value = "Error al iniciar test";

      Get.snackbar(
        'Error',
        'Error al iniciar test automático: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Verificar si todas las pruebas están completas
  void _checkAllTestsCompleted(bool _) {
    bool movementComplete = movementTests.values.every((test) => test.value);
    bool solenoidComplete = solenoidTests.values.every((test) => test.value);

    allTestsCompleted.value = movementComplete && solenoidComplete;

    // Solo auto-navegar si viene desde configuración
    if (allTestsCompleted.value &&
        comeFromConfig.value &&
        autoNavigateToDriving.value) {
      Timer(const Duration(seconds: 2), () {
        Get.offNamed('/mandocontrol');
      });
    }
  } // Confirmar test visualmente (solo checklist, no envía comandos)

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

  // Navegar según el origen: Config→Driving, Otro→Config
  void navigateToConfiguration() {
    if (comeFromConfig.value && autoNavigateToDriving.value) {
      // Si viene desde configuración, ir directamente a driving
      Get.offNamed('/mandocontrol');
    } else {
      // Navegación normal a configuración (viene de otro lugar)
      Get.toNamed('/configuracionrobot');
    }
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
    _startAutomaticTest();
  }
}
