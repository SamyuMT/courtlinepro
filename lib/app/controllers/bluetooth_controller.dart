import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
  BluetoothCharacteristic? notifyCharacteristic;

  // Streams para la conexión
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;
  StreamSubscription<List<int>>? characteristicSubscription;

  // Callback para datos recibidos
  Function(String)? dataCallback;

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

  // Solicitar permisos como en la implementación exitosa
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      return statuses.values.every((status) => status.isGranted);
    }
    return true;
  }

  // Verificar si Bluetooth está disponible como en la implementación exitosa
  Future<bool> isBluetoothAvailable() async {
    if (!await FlutterBluePlus.isSupported) return false;
    return (await FlutterBluePlus.adapterState.first) ==
        BluetoothAdapterState.on;
  }

  // Verificar estado de Bluetooth
  Future<void> _checkBluetoothState() async {
    try {
      // Verificar si Bluetooth está disponible
      if (await FlutterBluePlus.isSupported == false) {
        Get.snackbar(
          'Bluetooth not available',
          'This device does not support Bluetooth',
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
        'Error checking Bluetooth status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Solicitar permisos
  Future<void> _requestPermissions() async {
    await requestPermissions();
  }

  // Iniciar búsqueda de dispositivos
  Future<void> startScanning() async {
    if (!isBluetoothEnabled.value) {
      Get.snackbar(
        'Bluetooth disabled',
        'Please turn on Bluetooth to search for devices.',
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
              : 'Unknown Device',
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
                : 'Unknown Device',
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
        'Error searching for devices: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }

  // Conectar usando la lógica de la implementación exitosa
  Future<void> connectToDevice(Map<String, dynamic> deviceInfo) async {
    if (isConnecting.value) return;

    isConnecting.value = true;
    selectedDevice.value = deviceInfo['address'];

    try {
      BluetoothDevice device = deviceInfo['device'];
      connectedDevice = device;

      // Escuchar estado de conexión (como en la implementación exitosa)
      connectionSubscription = device.connectionState.listen((state) {
        isConnected.value = state == BluetoothConnectionState.connected;

        if (state == BluetoothConnectionState.disconnected) {
          connectedDevice = null;
          writeCharacteristic = null;
          notifyCharacteristic = null;
          dataCallback = null;
          Get.snackbar(
            'Offline',
            'Connection to the device was lost',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });

      // Conectar al dispositivo
      await device.connect(timeout: const Duration(seconds: 10));

      // Descubrir servicios (como en la implementación exitosa)
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          // Buscar característica de escritura
          if (characteristic.properties.write ||
              characteristic.properties.writeWithoutResponse) {
            writeCharacteristic = characteristic;
          }

          // Buscar característica de notificación
          if (characteristic.properties.notify ||
              characteristic.properties.indicate) {
            notifyCharacteristic = characteristic;

            // Suscribirse a notificaciones (como en la implementación exitosa)
            await characteristic.setNotifyValue(true);
            characteristicSubscription = characteristic.lastValueStream.listen((
              value,
            ) {
              if (value.isNotEmpty) {
                try {
                  String received = String.fromCharCodes(value);
                  if (dataCallback != null) {
                    dataCallback!(received);
                  }
                } catch (e) {
                  // Si falla la decodificación, usar hex string
                  String hexString = value
                      .map((b) => b.toRadixString(16).padLeft(2, '0'))
                      .join(' ');
                  if (dataCallback != null) {
                    dataCallback!('HEX: $hexString');
                  }
                }
              }
            });
          }
        }
      }

      Get.snackbar(
        'Connected',
        'Connected to ${deviceInfo['name']} - Ready to send commands',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Connection error',
        'Could not connect to ${deviceInfo['name']}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnecting.value = false;
      selectedDevice.value = '';
    }
  }

  // Cerrar conexión como en la implementación exitosa
  Future<void> _closeConnection() async {
    try {
      await characteristicSubscription?.cancel();
      await connectionSubscription?.cancel();

      if (connectedDevice != null) {
        await connectedDevice!.disconnect();
      }

      connectedDevice = null;
      writeCharacteristic = null;
      notifyCharacteristic = null;
      dataCallback = null;
    } catch (e) {
      // Silenciar errores de desconexión
      print('Error disconnecting: $e');
    }
    isConnected.value = false;
  }

  // Enviar datos usando la lógica de la implementación exitosa
  Future<void> sendData(String data) async {
    if (writeCharacteristic == null) {
      throw Exception('No write characteristic available');
    }

    try {
      // Agregar CR y LF como en Arduino Serial Monitor (implementación exitosa)
      String message = '$data\r\n';
      List<int> bytes =
          message.codeUnits; // Usar codeUnits como en la implementación exitosa

      if (writeCharacteristic!.properties.writeWithoutResponse) {
        await writeCharacteristic!.write(bytes, withoutResponse: true);
      } else {
        await writeCharacteristic!.write(bytes);
      }
    } catch (e) {
      throw Exception('Error sending data: $e');
    }
  }

  // Configurar callback para datos recibidos
  void setDataListener(Function(String) callback) {
    dataCallback = callback;
  }

  // Desconectar del dispositivo actual
  Future<void> disconnect() async {
    await _closeConnection();
  }

  // Método adicional para disposar recursos
  @override
  void dispose() {
    _closeConnection();
    super.dispose();
  }

  // Obtener información de debug sobre la conexión HM-10
  String getConnectionDebugInfo() {
    if (!isConnected.value || connectedDevice == null) {
      return 'No device connected';
    }

    String info = 'Active HM-10 connection:\n';
    info += 'Device: ${connectedDevice!.platformName}\n';
    info += 'Address: ${connectedDevice!.remoteId}\n';
    info +=
        'Communication feature: ${writeCharacteristic?.uuid ?? "Not find"}\n';
    info +=
        'State: ${isConnected.value ? "Conected and ready" : "Desconected"}\n';

    return info;
  }

  // Navegar a pruebas del robot
  void navigateToRobotTests() {
    Get.toNamed('/pruebasrobot');
  }
}
