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
  BluetoothCharacteristic? readCharacteristic;

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

  // Conectar a un dispositivo (SIMPLIFICADO para HM-10)
  Future<void> connectToDevice(Map<String, dynamic> deviceInfo) async {
    if (isConnecting.value) return;

    isConnecting.value = true;
    selectedDevice.value = deviceInfo['address'];

    try {
      BluetoothDevice device = deviceInfo['device'];

      // Conectar al dispositivo SIN emparejamiento
      await device.connect(timeout: const Duration(seconds: 15));
      connectedDevice = device;

      // Configuración simple para HM-10
      await _setupHM10Characteristics();

      isConnected.value = true;

      Get.snackbar(
        'Conectado',
        'Conectado a ${deviceInfo['name']} - Listo para enviar comandos',
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
          readCharacteristic = null;
          dataCallback = null;
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

  // Configuración SIMPLE para HM-10 (módulo serial transparente)
  Future<void> _setupHM10Characteristics() async {
    if (connectedDevice == null) return;

    try {
      print('Configurando HM-10 para comunicación serial...');

      // Descubrir servicios
      List<BluetoothService> services = await connectedDevice!
          .discoverServices();
      print('Servicios encontrados: ${services.length}');

      // Reset características
      writeCharacteristic = null;
      readCharacteristic = null;

      // UUID específico del HM-10 para comunicación serial (solo para referencia)

      // Buscar el servicio y característica específicos del HM-10
      for (BluetoothService service in services) {
        print('Servicio: ${service.uuid}');

        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          String charUUID = characteristic.uuid.toString().toLowerCase();
          print('  Característica: $charUUID');

          // Para HM-10: misma característica sirve para leer y escribir
          if (charUUID.contains('ffe1') ||
              characteristic.properties.writeWithoutResponse ||
              (characteristic.properties.write &&
                  characteristic.properties.notify)) {
            writeCharacteristic = characteristic;
            readCharacteristic = characteristic;

            print('  ✓ HM-10 encontrado - Configurando comunicación serial');

            // Configurar notificaciones para recibir datos
            try {
              if (characteristic.properties.notify) {
                await characteristic.setNotifyValue(true);
                characteristic.lastValueStream.listen((value) {
                  if (value.isNotEmpty) {
                    String receivedData = String.fromCharCodes(value);
                    print('Serial recibido: $receivedData');
                    if (dataCallback != null) {
                      dataCallback!(receivedData);
                    }
                  }
                });
                print('  ✓ Notificaciones configuradas para recibir datos');
              }
            } catch (e) {
              print('  ⚠ Error configurando notificaciones: $e');
            }

            print('✓ HM-10 listo para comunicación serial');
            return; // Salir cuando encontremos la característica correcta
          }
        }
      }

      // Si no encontramos HM-10 específico, usar cualquier característica compatible
      if (writeCharacteristic == null) {
        for (BluetoothService service in services) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.properties.writeWithoutResponse ||
                characteristic.properties.write) {
              writeCharacteristic = characteristic;
              print(
                '  ✓ Usando característica alternativa: ${characteristic.uuid}',
              );
              break;
            }
          }
          if (writeCharacteristic != null) break;
        }
      }

      if (writeCharacteristic == null) {
        throw Exception('No se encontró ninguna característica de escritura');
      }

      print('Configuración completada - Listo para enviar comandos seriales');
    } catch (e) {
      print('Error configurando HM-10: $e');
      throw Exception('Error configurando comunicación serial: $e');
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
      readCharacteristic = null;
      dataCallback = null;
    }
    isConnected.value = false;
  }

  // Enviar datos al dispositivo (SIMPLIFICADO para HM-10)
  Future<void> sendData(String data) async {
    if (writeCharacteristic == null || !isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'Dispositivo no conectado. Conéctate primero al HM-10.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Convertir string a bytes (como Serial Bluetooth Terminal)
      List<int> bytes = data.codeUnits;

      print('Enviando comando serial: "$data"');

      // Enviar directamente sin complicaciones (como HM-10)
      if (writeCharacteristic!.properties.writeWithoutResponse) {
        // Método preferido para HM-10
        await writeCharacteristic!.write(bytes, withoutResponse: true);
        print('✓ Comando enviado exitosamente: $data');
      } else if (writeCharacteristic!.properties.write) {
        // Método alternativo
        await writeCharacteristic!.write(bytes, withoutResponse: false);
        print('✓ Comando enviado exitosamente: $data');
      } else {
        throw Exception('La característica no soporta escritura');
      }

      // Confirmación visual opcional (solo para comandos importantes)
      if (data == 't') {
        Get.snackbar(
          'Test iniciado',
          'Comando "t" enviado al robot',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error al enviar comando: $e');
      Get.snackbar(
        'Error de comunicación',
        'No se pudo enviar el comando "$data". Verifica la conexión.',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  // Obtener información de debug sobre la conexión HM-10
  String getConnectionDebugInfo() {
    if (!isConnected.value || connectedDevice == null) {
      return 'No hay dispositivo conectado';
    }

    String info = 'Conexión HM-10 activa:\n';
    info += 'Dispositivo: ${connectedDevice!.platformName}\n';
    info += 'Dirección: ${connectedDevice!.remoteId}\n';
    info +=
        'Característica de comunicación: ${writeCharacteristic?.uuid ?? "No encontrada"}\n';
    info +=
        'Estado: ${isConnected.value ? "Conectado y listo" : "Desconectado"}\n';

    return info;
  }

  // Navegar a pruebas del robot
  void navigateToRobotTests() {
    Get.toNamed('/pruebasrobot');
  }
}
