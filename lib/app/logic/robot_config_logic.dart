class RobotConfigLogic {
  // Límites de velocidad
  static const double minLinearVelocity = 1.0;
  static const double maxLinearVelocity = 50.0;
  static const double minAngularVelocity = 1.0;
  static const double maxAngularVelocity = 20.0;

  // Generar comando de velocidad lineal
  static String generateLinearVelocityCommand(double velocity) {
    return 'SET_LINEAR_VEL:${velocity.toStringAsFixed(2)}';
  }

  // Generar comando de velocidad angular
  static String generateAngularVelocityCommand(double velocity) {
    return 'SET_ANGULAR_VEL:${velocity.toStringAsFixed(2)}';
  }

  // Generar comandos completos de configuración
  static List<String> generateCompleteConfigCommands(
    double linearVel,
    double angularVel,
  ) {
    return [
      'CONFIG_START',
      generateLinearVelocityCommand(linearVel),
      generateAngularVelocityCommand(angularVel),
      'CONFIG_END',
      'CONFIG_APPLY',
    ];
  }

  // Obtener comandos de prueba de configuración
  static List<String> getConfigurationTestCommands() {
    return [
      'TEST_FORWARD_SHORT',
      'TEST_BACKWARD_SHORT',
      'TEST_TURN_LEFT_SHORT',
      'TEST_TURN_RIGHT_SHORT',
      'TEST_STOP',
    ];
  }

  // Validar configuración de velocidades
  static bool validateVelocityConfiguration(
    double linearVel,
    double angularVel,
  ) {
    bool linearValid =
        linearVel >= minLinearVelocity && linearVel <= maxLinearVelocity;
    bool angularValid =
        angularVel >= minAngularVelocity && angularVel <= maxAngularVelocity;

    return linearValid && angularValid;
  }

  // Calcular velocidad óptima basada en el terreno
  static Map<String, double> calculateOptimalVelocities(String terrainType) {
    switch (terrainType.toLowerCase()) {
      case 'grass':
        return {'linear': 8.0, 'angular': 6.0};
      case 'concrete':
        return {'linear': 15.0, 'angular': 10.0};
      case 'clay':
        return {'linear': 12.0, 'angular': 8.0};
      default:
        return {'linear': 10.22, 'angular': 10.22};
    }
  }

  // Ajustar velocidades por condiciones ambientales
  static Map<String, double> adjustForWeatherConditions(
    double baseLinear,
    double baseAngular,
    String weatherCondition,
  ) {
    double linearFactor = 1.0;
    double angularFactor = 1.0;

    switch (weatherCondition.toLowerCase()) {
      case 'wet':
        linearFactor = 0.7;
        angularFactor = 0.8;
        break;
      case 'windy':
        linearFactor = 0.9;
        angularFactor = 0.9;
        break;
      case 'hot':
        linearFactor = 0.85;
        angularFactor = 0.9;
        break;
      default:
        // Condiciones normales
        break;
    }

    return {
      'linear': (baseLinear * linearFactor).clamp(
        minLinearVelocity,
        maxLinearVelocity,
      ),
      'angular': (baseAngular * angularFactor).clamp(
        minAngularVelocity,
        maxAngularVelocity,
      ),
    };
  }

  // Generar perfil de velocidad personalizado
  static Map<String, double> generateCustomProfile(
    String profileName,
    double aggressiveness, // 0.0 - 1.0
  ) {
    double baseLinear = 10.22;
    double baseAngular = 10.22;

    switch (profileName.toLowerCase()) {
      case 'precise':
        baseLinear = 5.0;
        baseAngular = 4.0;
        break;
      case 'fast':
        baseLinear = 20.0;
        baseAngular = 15.0;
        break;
      case 'balanced':
        baseLinear = 12.0;
        baseAngular = 10.0;
        break;
    }

    // Aplicar factor de agresividad
    double finalLinear =
        baseLinear + (aggressiveness * (maxLinearVelocity - baseLinear));
    double finalAngular =
        baseAngular + (aggressiveness * (maxAngularVelocity - baseAngular));

    return {
      'linear': finalLinear.clamp(minLinearVelocity, maxLinearVelocity),
      'angular': finalAngular.clamp(minAngularVelocity, maxAngularVelocity),
    };
  }

  // Validar que las velocidades sean seguras para el robot
  static bool isConfigurationSafe(double linearVel, double angularVel) {
    // Verificar límites básicos
    if (!validateVelocityConfiguration(linearVel, angularVel)) {
      return false;
    }

    // Verificar relación entre velocidades (evitar configuraciones peligrosas)
    double velocityRatio = linearVel / angularVel;
    if (velocityRatio > 5.0 || velocityRatio < 0.2) {
      return false; // Relación muy desbalanceada
    }

    return true;
  }

  // Obtener recomendaciones de configuración
  static List<String> getConfigurationRecommendations(
    double currentLinear,
    double currentAngular,
  ) {
    List<String> recommendations = [];

    if (currentLinear > maxLinearVelocity * 0.8) {
      recommendations.add(
        'Velocidad lineal muy alta - considera reducirla para mayor precisión',
      );
    }

    if (currentAngular > maxAngularVelocity * 0.8) {
      recommendations.add(
        'Velocidad angular muy alta - puede causar inestabilidad',
      );
    }

    if (currentLinear < minLinearVelocity * 2) {
      recommendations.add(
        'Velocidad lineal muy baja - el robot puede ser muy lento',
      );
    }

    double ratio = currentLinear / currentAngular;
    if (ratio > 3.0) {
      recommendations.add(
        'Incrementa la velocidad angular para mejor maniobrabilidad',
      );
    } else if (ratio < 0.5) {
      recommendations.add(
        'Incrementa la velocidad lineal para mejor eficiencia',
      );
    }

    return recommendations;
  }
}
