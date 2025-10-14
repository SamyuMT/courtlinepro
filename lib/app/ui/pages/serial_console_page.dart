import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/serial_console_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_theme.dart';

class SerialConsolePage extends GetView<SerialConsoleController> {
  const SerialConsolePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 16),

                // Status y controles
                _buildStatusBar(),

                const SizedBox(height: 16),

                // Console principal
                Expanded(child: _buildConsole()),

                const SizedBox(height: 16),

                // Input y comandos
                _buildInputArea(),

                const SizedBox(height: 16),

                // Botones de navegación
                _buildNavigationButtons(),
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
        Text("SERIAL CONSOLE DEBUG", style: AppTextStyles.appHeader),
        Text("v1.0", style: AppTextStyles.version),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Obx(
                () => Icon(
                  Icons.bluetooth_connected,
                  color: controller.isConnected.value
                      ? Colors.green
                      : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  controller.isConnected.value ? "Conectado" : "Desconectado",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: controller.isConnected.value
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: controller.clearConsole,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Limpiar",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text("Debug Info"),
                      content: Text(controller.getDebugInfo()),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Info",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsole() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              const Text(
                "Serial Monitor (Arduino Style)",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              child: Obx(
                () => ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.consoleMessages.length,
                  itemBuilder: (context, index) {
                    String message = controller.consoleMessages[index];
                    Color textColor = Colors.greenAccent;

                    // Colorear según tipo de mensaje
                    if (message.contains("SYS:")) {
                      textColor = Colors.yellow;
                    } else if (message.contains(">>>")) {
                      textColor = Colors.cyan;
                    } else if (message.contains("Error")) {
                      textColor = Colors.red;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Column(
      children: [
        // Campo de entrada
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.textController,
                  onChanged: (value) => controller.inputText.value = value,
                  onSubmitted: (value) => controller.sendCommand(value),
                  decoration: const InputDecoration(
                    hintText: "Escribe comando (t, c, r, s, w, x, etc.)",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    controller.sendCommand(controller.textController.text),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Enviar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Comandos rápidos
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Comandos Rápidos:",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickCommand("t", "Test Mode"),
                  _buildQuickCommand("c", "Config Mode"),
                  _buildQuickCommand("r", "Remote Mode"),
                  _buildQuickCommand("s", "Toggle Solenoid"),
                  _buildQuickCommand("w", "Forward"),
                  _buildQuickCommand("x", "Reverse"),
                  _buildQuickCommand("0.15,0.3", "Set Velocity"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCommand(String command, String description) {
    return GestureDetector(
      onTap: () => controller.sendPredefinedCommand(command),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              command,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            Text(
              description,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: "TESTS",
            onPressed: controller.navigateToTests,
            height: 50,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: "CONFIGURACIÓN",
            onPressed: controller.navigateToConfiguration,
            height: 50,
          ),
        ),
      ],
    );
  }
}
