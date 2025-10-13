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

                const SizedBox(width: 24),

                // Botón de reinicio
                _buildRestartButton(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Testing begins:", style: AppTextStyles.instructions),
          SizedBox(height: 4),
          Text(
            "Here are the instructions that the user must follow.",
            style: AppTextStyles.instructions,
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
                    () => controller.executeTest('forward'),
                  ),
                  _buildTestItem(
                    "Reverse movement",
                    controller.movementTests['reverse']!.value,
                    () => controller.executeTest('reverse'),
                  ),
                  _buildTestItem(
                    "Right turn",
                    controller.movementTests['right']!.value,
                    () => controller.executeTest('right'),
                  ),
                  _buildTestItem(
                    "Left turn",
                    controller.movementTests['left']!.value,
                    () => controller.executeTest('left'),
                  ),
                  _buildTestItem(
                    "In-place rotation",
                    controller.movementTests['rotation']!.value,
                    () => controller.executeTest('rotation'),
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
                    () => controller.executeTest('solenoid_off'),
                  ),
                  _buildTestItem(
                    "solenoid valve on",
                    controller.solenoidTests['on']!.value,
                    () => controller.executeTest('solenoid_on'),
                  ),
                  _buildTestItem(
                    "solenoid valve on in motion",
                    controller.solenoidTests['motion']!.value,
                    () => controller.executeTest('solenoid_motion'),
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

  Widget _buildRestartButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono de reinicio
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            onPressed: controller.restartTests,
            icon: const Icon(Icons.refresh, color: Colors.black, size: 30),
          ),
        ),

        const SizedBox(height: 8),

        const Text("restart", style: AppTextStyles.small),
      ],
    );
  }
}
