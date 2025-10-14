import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../themes/app_colors.dart';

class DevNavigationWidget extends StatelessWidget {
  const DevNavigationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_mode, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Navegación de Desarrollo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildNavButton(
                'Home',
                Icons.home,
                () => Get.offAllNamed(AppRoutes.home),
              ),
              _buildNavButton(
                'Bluetooth',
                Icons.bluetooth,
                () => Get.offAllNamed(AppRoutes.bluetoothConnection),
              ),
              _buildNavButton(
                'Pruebas Robot',
                Icons.science,
                () => Get.offAllNamed(AppRoutes.robotTests),
              ),
              _buildNavButton(
                'Configuración',
                Icons.settings,
                () => Get.offAllNamed(AppRoutes.robotConfig),
              ),
              _buildNavButton(
                'Control Manual',
                Icons.gamepad,
                () => Get.offAllNamed(AppRoutes.manualControl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(80, 32),
      ),
    );
  }
}
