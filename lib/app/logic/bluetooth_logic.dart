import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothLogic {
  // Validar que Bluetooth esté disponible en el dispositivo
  static Future<bool> isBluetoothSupported() async {
    try {
      return await FlutterBluePlus.isAvailable;
    } catch (e) {
      return false;
    }
  }

  // Solicitar activación de Bluetooth
  static Future<bool> requestBluetoothActivation() async {
    try {
      BluetoothAdapterState currentState =
          await FlutterBluePlus.adapterState.first;

      if (currentState != BluetoothAdapterState.on) {
        // Flutter Blue Plus no tiene método directo para activar Bluetooth
        // El usuario debe activarlo manualmente
        Get.snackbar(
          'Bluetooth desactivado',
          'Por favor, activa el Bluetooth desde la configuración del dispositivo',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al verificar Bluetooth: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  } // Verificar permisos necesarios

  static Future<bool> checkBluetoothPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      return statuses.values.every(
        (status) => status == PermissionStatus.granted,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al verificar permisos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Validar dirección MAC de Bluetooth
  static bool isValidMacAddress(String address) {
    if (address.isEmpty) return false;

    // Regex para validar formato de dirección MAC (XX:XX:XX:XX:XX:XX)
    RegExp macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    return macRegex.hasMatch(address);
  }

  // Filtrar dispositivos por nombre (buscar dispositivos del robot)
  static List<Map<String, dynamic>> filterRobotDevices(
    List<Map<String, dynamic>> devices,
  ) {
    // Filtros comunes para dispositivos de robots
    List<String> robotKeywords = [
      'robot',
      'courtline',
      'esp32',
      'arduino',
      'bt',
      'ble',
    ];

    return devices.where((device) {
      String deviceName = (device['name'] ?? '').toLowerCase();
      return robotKeywords.any((keyword) => deviceName.contains(keyword));
    }).toList();
  }

  // Verificar si un dispositivo es confiable para conectarse
  static bool isDeviceTrusted(Map<String, dynamic> device) {
    // Verificar si es un dispositivo emparejado previamente
    if (device['type'] == 'bonded') return true;

    // Verificar si el nombre contiene palabras clave del robot
    String deviceName = (device['name'] ?? '').toLowerCase();
    List<String> trustedKeywords = ['courtline', 'robot'];

    return trustedKeywords.any((keyword) => deviceName.contains(keyword));
  }

  // Generar comandos de prueba para el robot
  static List<String> getRobotTestCommands() {
    return [
      'FORWARD',
      'BACKWARD',
      'LEFT',
      'RIGHT',
      'ROTATE_CW',
      'ROTATE_CCW',
      'STOP',
      'SOLENOID_ON',
      'SOLENOID_OFF',
    ];
  }
}
