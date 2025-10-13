import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/robot_config_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_theme.dart';

class RobotConfigPage extends GetView<RobotConfigController> {
  const RobotConfigPage({Key? key}) : super(key: key);

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
                // Header
                _buildHeader(),

                const SizedBox(height: 40),

                // Contenido principal
                Expanded(
                  child: Column(
                    children: [
                      // Título de configuración
                      _buildConfigTitle(),

                      const SizedBox(height: 32),

                      // Controles de configuración
                      Expanded(child: _buildConfigControls()),

                      const SizedBox(height: 24),

                      // Botón de probar cambios
                      _buildTestButton(),

                      const SizedBox(height: 16),

                      // Botón de empezar a manejar
                      _buildStartDrivingButton(),
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

  Widget _buildConfigTitle() {
    return const Text(
      "Robot configuration",
      style: AppTextStyles.sectionSubtitle,
    );
  }

  Widget _buildConfigControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Velocidad lineal
          _buildVelocityControl(
            "Linear velocity",
            controller.linearVelocity,
            "cm/s",
            controller.updateLinearVelocity,
          ),

          const SizedBox(height: 32),

          // Velocidad angular
          _buildVelocityControl(
            "Angular velocity",
            controller.angularVelocity,
            "rad/s",
            controller.updateAngularVelocity,
          ),
        ],
      ),
    );
  }

  Widget _buildVelocityControl(
    String label,
    RxDouble velocity,
    String unit,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.configLabel),

        const SizedBox(height: 16),

        Row(
          children: [
            // Botones de incremento/decremento
            Column(
              children: [
                // Botón aumentar
                GestureDetector(
                  onTap: () => onChanged(velocity.value + 0.1),
                  child: Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Botón disminuir
                GestureDetector(
                  onTap: () => onChanged(velocity.value - 0.1),
                  child: Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 24),

            // Valor actual
            Expanded(
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      velocity.value.toStringAsFixed(2),
                      style: AppTextStyles.valueDisplay,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(unit, style: AppTextStyles.unitLabel),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestButton() {
    return PrimaryButton(
      text: "TEST CHANGES",
      onPressed: controller.testChanges,
      width: double.infinity,
      height: 60,
      textStyle: AppTextStyles.buttonMedium,
    );
  }

  Widget _buildStartDrivingButton() {
    return PrimaryButton(
      text: "START DRIVING",
      onPressed: controller.navigateToManualControl,
      width: double.infinity,
      height: 60,
      textStyle: AppTextStyles.buttonMedium,
    );
  }
}
