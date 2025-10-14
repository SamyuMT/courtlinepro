import 'dart:async';
import 'package:get/get.dart';
import '../logic/manual_control_logic.dart';
import 'bluetooth_controller.dart';
import 'robot_config_controller.dart';

class ManualControlController extends GetxController {
  // Obtener otros controladores
  late BluetoothController bluetoothController;
  late RobotConfigController configController;

  // Estados de velocidad actual
  var currentLinearVelocity = 0.0.obs;
  var currentAngularVelocity = 0.0.obs;
  var currentSpeed = 1.0.obs; // Factor de velocidad (0.1 - 2.0)

  // Estados de movimiento
  var isMoving = false.obs;
  var currentDirection = ''.obs;
  var isSolenoidActive = false.obs;

  // Estados de UI
  var isDashboardVisible = false.obs;
  var isCameraVisible = false.obs;

  // Timer para movimiento continuo
  Timer? movementTimer;

  @override
  void onInit() {
    super.onInit();
    try {
      bluetoothController = Get.find<BluetoothController>();
      configController = Get.find<RobotConfigController>();
      _initializeVelocities();
    } catch (e) {
      Get.snackbar(
        'Error de inicialización',
        'No se pudieron cargar los controladores necesarios',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Verificar conexión
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth activa',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
    stopMovement();
    movementTimer?.cancel();
  }

  // Inicializar velocidades desde la configuración
  void _initializeVelocities() {
    currentLinearVelocity.value = configController.linearVelocity.value;
    currentAngularVelocity.value = configController.angularVelocity.value;
  }

  // Iniciar movimiento en una dirección
  void startMovement(String direction) {
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    currentDirection.value = direction;
    isMoving.value = true;

    // Enviar comando inicial
    _sendMovementCommand(direction);

    // Configurar timer para movimiento continuo
    movementTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _sendMovementCommand(direction),
    );
  }

  // Detener movimiento
  void stopMovement() {
    movementTimer?.cancel();
    isMoving.value = false;
    currentDirection.value = '';

    if (bluetoothController.isConnected.value) {
      _sendStopCommand();
    }
  }

  // Enviar comando de movimiento
  Future<void> _sendMovementCommand(String direction) async {
    try {
      String command = ManualControlLogic.generateMovementCommand(
        direction,
        _calculateCurrentLinearVelocity(),
        _calculateCurrentAngularVelocity(),
      );

      await bluetoothController.sendData(command);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al enviar comando de movimiento: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Enviar comando de parada
  Future<void> _sendStopCommand() async {
    try {
      String command = ManualControlLogic.generateStopCommand();
      await bluetoothController.sendData(command);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al enviar comando de parada: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Calcular velocidad lineal actual con factor de velocidad
  double _calculateCurrentLinearVelocity() {
    return currentLinearVelocity.value * currentSpeed.value;
  }

  // Calcular velocidad angular actual con factor de velocidad
  double _calculateCurrentAngularVelocity() {
    return currentAngularVelocity.value * currentSpeed.value;
  }

  // Incrementar velocidad
  void increaseSpeed() {
    if (currentSpeed.value < 2.0) {
      currentSpeed.value = (currentSpeed.value + 0.1).clamp(0.1, 2.0);

      Get.snackbar(
        'Velocidad aumentada',
        'Factor de velocidad: ${(currentSpeed.value * 100).round()}%',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Disminuir velocidad
  void decreaseSpeed() {
    if (currentSpeed.value > 0.1) {
      currentSpeed.value = (currentSpeed.value - 0.1).clamp(0.1, 2.0);

      Get.snackbar(
        'Velocidad reducida',
        'Factor de velocidad: ${(currentSpeed.value * 100).round()}%',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Alternar solenoide
  Future<void> toggleSolenoid() async {
    if (!bluetoothController.isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'No hay conexión Bluetooth',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSolenoidActive.value = !isSolenoidActive.value;

      String command = ManualControlLogic.generateSolenoidCommand(
        isSolenoidActive.value,
      );

      await bluetoothController.sendData(command);

      Get.snackbar(
        'Solenoide ${isSolenoidActive.value ? 'activado' : 'desactivado'}',
        '',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      // Revertir estado en caso de error
      isSolenoidActive.value = !isSolenoidActive.value;

      Get.snackbar(
        'Error',
        'Error al controlar solenoide: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Abrir configuraciones
  void openSettings() {
    Get.snackbar(
      'Configuraciones',
      'Abriendo panel de configuraciones...',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Aquí se puede implementar un diálogo o navegar a configuraciones
    // Por ejemplo: Get.toNamed('/configuracionrobot');
  }

  // Alternar dashboard
  void toggleDashboard() {
    isDashboardVisible.value = !isDashboardVisible.value;

    Get.snackbar(
      'Dashboard ${isDashboardVisible.value ? 'visible' : 'oculto'}',
      '',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // Abrir cámara
  void openCamera() {
    isCameraVisible.value = !isCameraVisible.value;

    Get.snackbar(
      'Cámara ${isCameraVisible.value ? 'activada' : 'desactivada'}',
      '',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // Parada de emergencia
  void emergencyStop() {
    stopMovement();

    // Desactivar solenoide
    if (isSolenoidActive.value) {
      toggleSolenoid();
    }

    Get.snackbar(
      'PARADA DE EMERGENCIA',
      'Todos los sistemas detenidos',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  // Obtener estado del robot
  Map<String, dynamic> getRobotStatus() {
    return {
      'connected': bluetoothController.isConnected.value,
      'moving': isMoving.value,
      'direction': currentDirection.value,
      'solenoid': isSolenoidActive.value,
      'linear_velocity': _calculateCurrentLinearVelocity(),
      'angular_velocity': _calculateCurrentAngularVelocity(),
      'speed_factor': currentSpeed.value,
    };
  }

  // Aplicar configuración rápida
  void applyQuickConfig(String configType) {
    switch (configType) {
      case 'slow':
        currentSpeed.value = 0.5;
        break;
      case 'normal':
        currentSpeed.value = 1.0;
        break;
      case 'fast':
        currentSpeed.value = 1.5;
        break;
    }

    Get.snackbar(
      'Configuración aplicada',
      'Velocidad ajustada a modo $configType',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
