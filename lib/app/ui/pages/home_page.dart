import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_theme.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Versión en la parte superior derecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [Text("v1.0", style: AppTextStyles.version)],
                ),

                // Contenido central
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título principal
                      Column(
                        children: const [
                          Text(
                            "COURTLINE",
                            style: AppTextStyles.mainTitle,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "PRO",
                            style: AppTextStyles.mainTitle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Subtítulo
                      const Text(
                        "app for robot control",
                        style: AppTextStyles.subtitle,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 80),

                      // Botón START
                      StartButton(
                        onPressed: controller.navigateToBluetoothConnection,
                      ),
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
}
