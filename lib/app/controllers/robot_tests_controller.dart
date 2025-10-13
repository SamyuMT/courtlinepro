import 'package:get/get.dart';
import '../logic/robot_tests_logic.dart';
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

  @override
  void onInit() {
    super.onInit();
    bluetoothController = Get.find<BluetoothController>();
    _setupTestsListener();
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

  // Verificar si todas las pruebas están completas
  void _checkAllTestsCompleted(bool _) {
    bool movementComplete = movementTests.values.every((test) => test.value);
    bool solenoidComplete = solenoidTests.values.every((test) => test.value);

    allTestsCompleted.value = movementComplete && solenoidComplete;
  }

  // Ejecutar una prueba específica
  Future<void> executeTest(String testType) async {
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth para ejecutar la prueba',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    currentlyTesting.value = testType;

    try {
      String command = RobotTestsLogic.getTestCommand(testType);

      if (command.isNotEmpty) {
        // Enviar comando al robot
        await bluetoothController.sendData(command);

        // Simular tiempo de ejecución de la prueba
        await Future.delayed(const Duration(seconds: 2));

        // Marcar la prueba como completada
        _markTestCompleted(testType);

        Get.snackbar(
          'Prueba completada',
          RobotTestsLogic.getTestDescription(testType),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error en prueba',
        'Error al ejecutar la prueba: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      currentlyTesting.value = '';
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

    Get.snackbar(
      'Pruebas reiniciadas',
      'Todas las pruebas han sido reiniciadas',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Navegar a configuración del robot
  void navigateToConfiguration() {
    Get.toNamed('/configuracionrobot');
  }

  // Ejecutar todas las pruebas automáticamente (función de prueba)
  Future<void> runAllTestsAutomatically() async {
    List<String> testSequence = [
      'forward',
      'reverse',
      'right',
      'left',
      'rotation',
      'solenoid_off',
      'solenoid_on',
      'solenoid_motion',
    ];

    for (String test in testSequence) {
      await executeTest(test);
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
