import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  // Estado de Bluetooth
  var isBluetoothEnabled = false.obs;
  var isConnected = false.obs;
  var isScanning = false.obs;
  var isConnecting = false.obs;

  // Dispositivos disponibles
  var availableDevices = <Map<String, dynamic>>[].obs;
  var selectedDevice = ''.obs;

  // Conexión Bluetooth
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;

  @override
  void onInit() {
    super.onInit();
    _checkBluetoothState();
  }

  @override
  void onReady() {
    super.onReady();
    _requestPermissions();
  }

  @override
  void onClose() {
    super.onClose();
    _closeConnection();
  }

  // Verificar estado de Bluetooth
  Future<void> _checkBluetoothState() async {
    try {
      // Verificar si Bluetooth está disponible
      if (await FlutterBluePlus.isAvailable == false) {
        Get.snackbar(
          'Bluetooth no disponible',
          'Este dispositivo no soporta Bluetooth',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Obtener estado actual
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      isBluetoothEnabled.value = state == BluetoothAdapterState.on;

      // Escuchar cambios en el estado de Bluetooth
      FlutterBluePlus.adapterState.listen((state) {
        isBluetoothEnabled.value = state == BluetoothAdapterState.on;
        if (state != BluetoothAdapterState.on) {
          isConnected.value = false;
          availableDevices.clear();
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al verificar el estado de Bluetooth: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Solicitar permisos
  Future<void> _requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every(
        (status) => status == PermissionStatus.granted,
      );

      if (!allGranted) {
        Get.snackbar(
          'Permisos requeridos',
          'La aplicación necesita permisos de Bluetooth para funcionar correctamente.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al solicitar permisos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Iniciar búsqueda de dispositivos
  Future<void> startScanning() async {
    if (!isBluetoothEnabled.value) {
      Get.snackbar(
        'Bluetooth desactivado',
        'Por favor, activa el Bluetooth para buscar dispositivos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isScanning.value = true;
    availableDevices.clear();

    try {
      // Obtener dispositivos emparejados (conectados o bondeados)
      List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
      for (BluetoothDevice device in connectedDevices) {
        availableDevices.add({
          'name': device.platformName.isNotEmpty
              ? device.platformName
              : 'Dispositivo desconocido',
          'address': device.remoteId.toString(),
          'type': 'connected',
          'device': device,
        });
      }

      // Iniciar escaneo
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      // Escuchar resultados del escaneo
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final existingIndex = availableDevices.indexWhere(
            (element) =>
                element['address'] == result.device.remoteId.toString(),
          );

          Map<String, dynamic> deviceInfo = {
            'name': result.device.platformName.isNotEmpty
                ? result.device.platformName
                : result.advertisementData.localName.isNotEmpty
                ? result.advertisementData.localName
                : 'Dispositivo desconocido',
            'address': result.device.remoteId.toString(),
            'type': 'discovered',
            'device': result.device,
            'rssi': result.rssi,
          };

          if (existingIndex >= 0) {
            availableDevices[existingIndex] = deviceInfo;
          } else {
            availableDevices.add(deviceInfo);
          }
        }
      });

      // Esperar a que termine el escaneo
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al buscar dispositivos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }

  // Conectar a un dispositivo
  Future<void> connectToDevice(Map<String, dynamic> deviceInfo) async {
    if (isConnecting.value) return;

    isConnecting.value = true;
    selectedDevice.value = deviceInfo['address'];

    try {
      BluetoothDevice device = deviceInfo['device'];

      // Conectar al dispositivo
      await device.connect();
      connectedDevice = device;

      // Descubrir servicios
      List<BluetoothService> services = await device.discoverServices();

      // Buscar una característica para escribir (Serial Port Profile o similar)
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write) {
            writeCharacteristic = characteristic;
            break;
          }
        }
        if (writeCharacteristic != null) break;
      }

      isConnected.value = true;

      Get.snackbar(
        'Conectado',
        'Conectado a ${deviceInfo['name']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Escuchar desconexiones
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          isConnected.value = false;
          connectedDevice = null;
          writeCharacteristic = null;
          Get.snackbar(
            'Desconectado',
            'Se perdió la conexión con el dispositivo',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error de conexión',
        'No se pudo conectar a ${deviceInfo['name']}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnecting.value = false;
      selectedDevice.value = '';
    }
  }

  // Cerrar conexión
  Future<void> _closeConnection() async {
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
      } catch (e) {
        print('Error al desconectar: $e');
      }
      connectedDevice = null;
      writeCharacteristic = null;
    }
    isConnected.value = false;
  }

  // Enviar datos al dispositivo
  Future<void> sendData(String data) async {
    if (writeCharacteristic != null && isConnected.value) {
      try {
        List<int> bytes = data.codeUnits;
        await writeCharacteristic!.write(bytes, withoutResponse: true);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Error al enviar datos: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Sin conexión',
        'No hay dispositivo conectado o característica de escritura disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navegar a pruebas del robot
  void navigateToRobotTests() {
    Get.toNamed('/pruebasrobot');
  }
}
