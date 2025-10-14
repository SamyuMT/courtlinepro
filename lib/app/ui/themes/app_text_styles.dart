import 'package:flutter/material.dart';

class AppTextStyles {
  // Familia de fuentes base
  static const String _fontFamily = 'Roboto';

  // Título principal (COURTLINE PRO)
  static const TextStyle mainTitle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Subtítulo (app for robot control)
  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Botón principal (START)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Botones medianos
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Botones pequeños
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Encabezado de aplicación
  static const TextStyle appHeader = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Versión
  static const TextStyle version = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Títulos de sección
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontFamily: _fontFamily,
  );

  // Subtítulos de sección
  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: _fontFamily,
  );

  // Texto de configuración
  static const TextStyle configLabel = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontFamily: _fontFamily,
  );

  // Valores numéricos grandes
  static const TextStyle valueDisplay = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    fontFamily: _fontFamily,
  );

  // Unidades de medida
  static const TextStyle unitLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    fontFamily: _fontFamily,
  );

  // Texto de lista (checklist)
  static const TextStyle listItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    fontFamily: _fontFamily,
  );

  // Instrucciones
  static const TextStyle instructions = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    fontFamily: _fontFamily,
  );

  // Texto pequeño
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    fontFamily: _fontFamily,
  );

  // Estados de velocidad (pequeños)
  static const TextStyle speedValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: _fontFamily,
  );
}
