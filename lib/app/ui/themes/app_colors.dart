import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(
    0xFF1E3A5F,
  ); // Color azul principal del fondo
  static const Color secondary = Color(0xFF2D5A87); // Azul más claro
  static const Color accent = Color(
    0xFF006BFF,
  ); // Azul para botones y elementos activos
  static const Color accentGradientEnd = Color(
    0xFF2D83FA,
  ); // Final del gradiente azul

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFFD9D9D9);
  static const Color lightGrey = Color(0xFFD2D2D2);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Estados de conectividad
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFFF44336);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E3A5F), Color(0xFF4A90B8)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF006BFF), Color(0xFF2D83FA)],
  );
}
