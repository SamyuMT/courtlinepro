import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bluetooth_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_theme.dart';

class BluetoothConnectionPage extends GetView<BluetoothController> {
  const BluetoothConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con título y versión
                _buildHeader(),

                const SizedBox(height: 40),

                // Estado de Bluetooth y lista de dispositivos
                Expanded(
                  child: Column(
                    children: [
                      // Indicador de estado Bluetooth
                      _buildBluetoothStatus(),

                      const SizedBox(height: 40),

                      // Lista de dispositivos
                      Expanded(child: _buildDeviceList()),

                      const SizedBox(height: 20),

                      // Botón buscar BLE
                      _buildSearchButton(),

                      const SizedBox(height: 20),

                      // Botón continuar
                      _buildContinueButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("COURTLINE-PRO", style: AppTextStyles.appHeader),
        Text("v1.0", style: AppTextStyles.version),
      ],
    );
  }

  Widget _buildBluetoothStatus() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicadores de estado
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: controller.isBluetoothEnabled.value
                      ? AppColors.online
                      : AppColors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Icono de Bluetooth
              Icon(Icons.bluetooth, color: AppColors.white, size: 40),

              const SizedBox(width: 8),

              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: controller.isConnected.value
                      ? AppColors.online
                      : AppColors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Estado de conexión
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: controller.isConnected.value
                  ? AppColors.online
                  : AppColors.offline,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.isConnected.value ? "ON-LINE" : "OFF-LINE",
              style: AppTextStyles.buttonSmall,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDeviceList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() {
        if (controller.isScanning.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
                SizedBox(height: 16),
                Text(
                  "Buscando dispositivos...",
                  style: AppTextStyles.instructions,
                ),
              ],
            ),
          );
        }

        if (controller.availableDevices.isEmpty) {
          return const Center(
            child: Text(
              "No se encontraron dispositivos.\nPresiona 'SEARCH BLE' para buscar.",
              style: AppTextStyles.instructions,
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.availableDevices.length,
          itemBuilder: (context, index) {
            final device = controller.availableDevices[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  device['name'] ?? 'Dispositivo desconocido',
                  style: AppTextStyles.listItem.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  device['address'] ?? '',
                  style: AppTextStyles.small,
                ),
                trailing: Obx(
                  () =>
                      controller.isConnecting.value &&
                          controller.selectedDevice.value == device['address']
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios),
                ),
                onTap: () => controller.connectToDevice(device),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSearchButton() {
    return Obx(() {
      return PrimaryButton(
        text: "SEARCH BLE",
        onPressed: controller.isScanning.value
            ? null
            : controller.startScanning,
        width: double.infinity,
        height: 60,
        textStyle: AppTextStyles.buttonMedium,
      );
    });
  }

  Widget _buildContinueButton() {
    return Obx(() {
      return PrimaryButton(
        text: "CONTINUE",
        onPressed: controller.isConnected.value
            ? controller.navigateToRobotTests
            : null,
        width: double.infinity,
        height: 60,
        textStyle: AppTextStyles.buttonMedium,
      );
    });
  }
}
