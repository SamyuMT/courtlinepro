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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header con velocidades y título
                _buildHeader(),

                const SizedBox(height: 40),

                // Controles principales (6 botones en orientación horizontal)
                Expanded(child: _buildHorizontalControls()),
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
        // Título
        const Text("CONTROL MANUAL", style: AppTextStyles.appHeader),
        const SizedBox(height: 16),

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
      ],
    );
  }

  Widget _buildHorizontalControls() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fila superior: Izquierda, Acelerar, Derecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                svgAsset: 'assets/controles/izquierda.svg',
                onTapDown: (_) => controller.startTurn('left'),
                onTapUp: (_) => controller.stopTurn('left'),
                onTapCancel: () => controller.stopTurn('left'),
                label: 'GIRO IZQ',
              ),

              _buildControlButton(
                svgAsset: 'assets/controles/acelerar.svg',
                onPressed: () => controller.sendMovementCommand('w'),
                label: 'ACELERAR',
              ),

              _buildControlButton(
                svgAsset: 'assets/controles/derecha.svg',
                onTapDown: (_) => controller.startTurn('right'),
                onTapUp: (_) => controller.stopTurn('right'),
                onTapCancel: () => controller.stopTurn('right'),
                label: 'GIRO DER',
              ),
            ],
          ),
          const SizedBox(height: 60),

          // Fila inferior: Regar, Frenar, Reversa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                svgAsset: 'assets/controles/regar.svg',
                onPressed: () => controller.activateWatering(),
                label: 'REGAR',
              ),
              _buildControlButton(
                svgAsset: 'assets/controles/reversa.svg',
                onPressed: () => controller.sendMovementCommand('x'),
                label: 'REVERSA'),

              _buildControlButton(
                svgAsset: 'assets/controles/frenar.svg',
                onPressed: () => controller.sendMovementCommand('s'),
                label: 'FRENAR',
              )
              ,
            ],
          ),
        ],
      ),
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
    String? label,
  }) {
    Widget iconWidget;

    if (svgAsset != null) {
      iconWidget = SvgPicture.asset(
        svgAsset,
        width: 50,
        height: 50,
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
      );
    } else if (icon != null) {
      iconWidget = Icon(icon, color: Colors.black, size: 50);
    } else {
      iconWidget = Icon(Icons.help, color: Colors.black, size: 50);
    }

    Widget button = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Center(child: iconWidget),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.buttonSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
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
}
