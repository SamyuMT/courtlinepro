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

                // Contenido scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de configuración
                        _buildConfigTitle(),

                        const SizedBox(height: 32),

                        // Monitor BLE
                        _buildBleMonitor(),

                        const SizedBox(height: 24),

                        // Controles de configuración
                        _buildConfigControls(),

                        const SizedBox(height: 24),

                        // Botón de probar cambios
                        _buildTestButton(),

                        const SizedBox(height: 16),

                        // Botón de empezar a manejar
                        _buildStartDrivingButton(),

                        const SizedBox(height: 32), // Extra space at bottom
                      ],
                    ),
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

  Widget _buildBleMonitor() {
    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              const Text(
                "Configuration monitor:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Terminal de mensajes BLE
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Obx(() {
                if (controller.instructionMessages.isEmpty) {
                  return const Text(
                    "> Waiting for robot connection...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Mostrar mensajes más recientes abajo
                  itemCount: controller.instructionMessages.length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        controller.instructionMessages.length - 1 - index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        "> ${controller.instructionMessages[reverseIndex]}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
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

          const SizedBox(height: 32),

          // Botón Confirm
          PrimaryButton(
            text: "CONFIRM VELOCITIES",
            onPressed: controller.confirmVelocities,
            width: double.infinity,
            height: 50,
            textStyle: AppTextStyles.buttonMedium.copyWith(fontSize: 14),
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

            // Campo de texto para escribir velocidad
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  suffixText: unit,
                  suffixStyle: AppTextStyles.unitLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTextStyles.valueDisplay,
                controller: label == "Linear velocity"
                    ? controller.linearVelocityController
                    : controller.angularVelocityController,
                onSubmitted: (value) {
                  double? newValue = double.tryParse(value);
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
                onChanged: (value) {
                  double? newValue = double.tryParse(value);
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
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
    return Obx(() {
      return PrimaryButton(
        text: "START DRIVING",
        onPressed: controller.configurationSaved.value
            ? controller.navigateToManualControl
            : null,
        width: double.infinity,
        height: 60,
        textStyle: AppTextStyles.buttonMedium,
      );
    });
  }
}
