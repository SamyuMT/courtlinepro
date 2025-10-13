import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/manual_control_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class ManualControlPage extends GetView<ManualControlController> {
  const ManualControlPage({Key? key}) : super(key: key);

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
                // Header con velocidades
                _buildHeader(),

                const SizedBox(height: 16),

                // Contenido principal
                Expanded(
                  child: Row(
                    children: [
                      // Controles de movimiento
                      Expanded(flex: 2, child: _buildMovementControls()),

                      const SizedBox(width: 16),

                      // Panel lateral con información
                      Expanded(flex: 1, child: _buildSidePanel()),
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
    return Column(
      children: [
        // Indicadores de velocidad
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Velocidad lineal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.currentLinearVelocity.value.toStringAsFixed(2),
                      style: AppTextStyles.speedValue,
                    ),
                    const SizedBox(width: 4),
                    const Text("cm/s", style: AppTextStyles.speedValue),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Velocidad angular
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.currentAngularVelocity.value.toStringAsFixed(
                        2,
                      ),
                      style: AppTextStyles.speedValue,
                    ),
                    const SizedBox(width: 4),
                    const Text("rad/s", style: AppTextStyles.speedValue),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Título y botón de configuración
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("COURTLINE-PRO", style: AppTextStyles.appHeader),
            const Text("v1.0", style: AppTextStyles.version),
            Row(
              children: [
                const Text("SETTINGS", style: AppTextStyles.buttonSmall),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: controller.openSettings,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.settings,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMovementControls() {
    return Column(
      children: [
        // Fila superior de controles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Control izquierdo superior
            _buildControlButton(
              svgAsset: 'assets/controles/camera.svg',
              onPressed: controller.openCamera,
            ),

            // Control central superior
            _buildControlButton(
              svgAsset: 'assets/controles/up.svg',
              onTapDown: (_) => controller.startMovement('forward'),
              onTapUp: (_) => controller.stopMovement(),
              onTapCancel: controller.stopMovement,
            ),

            // Control derecho superior (dashboard)
            _buildControlButton(
              svgAsset: 'assets/controles/dashboard.svg',
              onPressed: controller.toggleDashboard,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Fila central de controles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Giro izquierda
            _buildControlButton(
              svgAsset: 'assets/controles/left.svg',
              onTapDown: (_) => controller.startMovement('left'),
              onTapUp: (_) => controller.stopMovement(),
              onTapCancel: controller.stopMovement,
            ),

            // Controles centrales (velocímetro y botones)
            Column(
              children: [
                // Velocímetro
                _buildSpeedometer(),

                const SizedBox(height: 16),

                // Botones up/down
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSmallControlButton(
                      svgAsset: 'assets/controles/arrow_up_small.svg',
                      onPressed: controller.increaseSpeed,
                    ),
                    const SizedBox(width: 8),
                    _buildSmallControlButton(
                      svgAsset: 'assets/controles/arrow_down_small.svg',
                      onPressed: controller.decreaseSpeed,
                    ),
                  ],
                ),
              ],
            ),

            // Giro derecha
            _buildControlButton(
              svgAsset: 'assets/controles/right.svg',
              onTapDown: (_) => controller.startMovement('right'),
              onTapUp: (_) => controller.stopMovement(),
              onTapCancel: controller.stopMovement,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Fila inferior de controles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Espacio
            const SizedBox(width: 62),

            // Control hacia atrás
            _buildControlButton(
              svgAsset: 'assets/controles/down.svg',
              onTapDown: (_) => controller.startMovement('backward'),
              onTapUp: (_) => controller.stopMovement(),
              onTapCancel: controller.stopMovement,
            ),

            // Control de solenoide
            Obx(
              () => _buildControlButton(
                svgAsset: controller.isSolenoidActive.value
                    ? 'assets/controles/solenoid.svg'
                    : 'assets/controles/solenoid_inactive.svg',
                onPressed: controller.toggleSolenoid,
                backgroundColor: controller.isSolenoidActive.value
                    ? AppColors.online
                    : AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    IconData? icon,
    String? svgAsset,
    VoidCallback? onPressed,
    void Function(TapDownDetails)? onTapDown,
    void Function(TapUpDetails)? onTapUp,
    VoidCallback? onTapCancel,
    Color backgroundColor = AppColors.lightGrey,
  }) {
    Widget iconWidget;

    if (svgAsset != null) {
      iconWidget = SvgPicture.asset(
        svgAsset,
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
      );
    } else if (icon != null) {
      iconWidget = Icon(icon, color: Colors.black, size: 30);
    } else {
      iconWidget = Icon(Icons.help, color: Colors.black, size: 30);
    }

    Widget button = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(31),
      ),
      child: iconWidget,
    );

    if (onTapDown != null || onTapUp != null) {
      return GestureDetector(
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        child: button,
      );
    } else {
      return GestureDetector(onTap: onPressed, child: button);
    }
  }

  Widget _buildSmallControlButton({
    IconData? icon,
    String? svgAsset,
    VoidCallback? onPressed,
  }) {
    Widget iconWidget;
    
    if (svgAsset != null) {
      iconWidget = SvgPicture.asset(
        svgAsset,
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
      );
    } else if (icon != null) {
      iconWidget = Icon(icon, color: Colors.black, size: 16);
    } else {
      iconWidget = Icon(Icons.help, color: Colors.black, size: 16);
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: iconWidget,
      ),
    );
  }

  Widget _buildSpeedometer() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: AppColors.grey, shape: BoxShape.circle),
      child: Obx(
        () => Center(
          child: Text(
            '${(controller.currentSpeed.value * 10).round()}',
            style: AppTextStyles.configLabel.copyWith(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
        // Panel vacío por ahora (se puede agregar información adicional)
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "Panel de información\n(Futuras funciones)",
                style: AppTextStyles.instructions,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
