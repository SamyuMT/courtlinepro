import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/robot_tests_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_theme.dart';

class RobotTestsPage extends GetView<RobotTestsController> {
  const RobotTestsPage({Key? key}) : super(key: key);

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
            child: Row(
              children: [
                // Contenido principal
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),

                      const SizedBox(height: 32),

                      // Instrucciones
                      _buildInstructions(),

                      const SizedBox(height: 24),

                      // Lista de pruebas
                      Expanded(child: _buildTestsList()),

                      const SizedBox(height: 24),

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

  Widget _buildInstructions() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.terminal, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    "Test monitor:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Indicador de estado del test y botón de reinicio
              Row(
                children: [
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: controller.testInitiated.value
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        controller.testInitiated.value
                            ? "In progress"
                            : "initializing...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
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
                    "> Esperando conexión del robot...",
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

  Widget _buildTestsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de movimiento del vehículo
          const Text(
            "Vehicle Movement Test\nChecklist",
            style: AppTextStyles.sectionTitle,
          ),

          const SizedBox(height: 20),

          // Lista de pruebas de movimiento
          Expanded(
            child: Obx(() {
              return ListView(
                children: [
                  _buildTestItem(
                    "Forward movement",
                    controller.movementTests['forward']!.value,
                    () => controller.confirmTest('forward'),
                  ),
                  _buildTestItem(
                    "Reverse movement",
                    controller.movementTests['reverse']!.value,
                    () => controller.confirmTest('reverse'),
                  ),
                  _buildTestItem(
                    "Right turn",
                    controller.movementTests['right']!.value,
                    () => controller.confirmTest('right'),
                  ),
                  _buildTestItem(
                    "Left turn",
                    controller.movementTests['left']!.value,
                    () => controller.confirmTest('left'),
                  ),
                  _buildTestItem(
                    "In-place rotation",
                    controller.movementTests['rotation']!.value,
                    () => controller.confirmTest('rotation'),
                  ),

                  const SizedBox(height: 24),

                  // Título de pruebas de solenoide
                  const Text(
                    "Feedwater inlet solenoid\nvalve connection test",
                    style: AppTextStyles.sectionTitle,
                  ),

                  const SizedBox(height: 16),

                  _buildTestItem(
                    "solenoid valve off",
                    controller.solenoidTests['off']!.value,
                    () => controller.confirmTest('solenoid_off'),
                  ),
                  _buildTestItem(
                    "solenoid valve on",
                    controller.solenoidTests['on']!.value,
                    () => controller.confirmTest('solenoid_on'),
                  ),
                  _buildTestItem(
                    "solenoid valve on in motion",
                    controller.solenoidTests['motion']!.value,
                    () => controller.confirmTest('solenoid_motion'),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTestItem(String title, bool isCompleted, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.listItem)),

          const SizedBox(width: 16),

          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: isCompleted ? AppColors.buttonGradient : null,
                color: isCompleted ? null : AppColors.grey,
                borderRadius: BorderRadius.circular(6.5),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Obx(() {
      return PrimaryButton(
        text: "CONTINUE",
        onPressed: controller.allTestsCompleted.value
            ? controller.navigateToConfiguration
            : null,
        width: double.infinity,
        height: 60,
        textStyle: AppTextStyles.buttonMedium,
      );
    });
  }
}
