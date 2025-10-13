class ManualControlLogic {
  // Comandos básicos de movimiento
  static const Map<String, String> _movementCommands = {
    'forward': 'MOVE_FORWARD',
    'backward': 'MOVE_BACKWARD',
    'left': 'TURN_LEFT',
    'right': 'TURN_RIGHT',
    'rotate_left': 'ROTATE_LEFT',
    'rotate_right': 'ROTATE_RIGHT',
  };

  // Generar comando de movimiento con velocidades
  static String generateMovementCommand(
    String direction,
    double linearVel,
    double angularVel,
  ) {
    String baseCommand = _movementCommands[direction] ?? 'STOP';
    return '$baseCommand:${linearVel.toStringAsFixed(2)}:${angularVel.toStringAsFixed(2)}';
  }

  // Generar comando de parada
  static String generateStopCommand() {
    return 'STOP:0.00:0.00';
  }

  // Generar comando de solenoide
  static String generateSolenoidCommand(bool activate) {
    return activate ? 'SOLENOID_ON' : 'SOLENOID_OFF';
  }

  // Generar comando de solenoide con movimiento
  static String generateSolenoidWithMovementCommand(
    bool solenoidActive,
    String direction,
    double linearVel,
    double angularVel,
  ) {
    String movementCmd = generateMovementCommand(
      direction,
      linearVel,
      angularVel,
    );
    String solenoidCmd = generateSolenoidCommand(solenoidActive);
    return '$movementCmd;$solenoidCmd';
  }

  // Validar comando de movimiento
  static bool isValidMovementDirection(String direction) {
    return _movementCommands.containsKey(direction);
  }

  // Calcular velocidad segura basada en dirección
  static Map<String, double> calculateSafeVelocities(
    String direction,
    double baseLinear,
    double baseAngular,
  ) {
    double linearFactor = 1.0;
    double angularFactor = 1.0;

    switch (direction) {
      case 'forward':
      case 'backward':
        // Movimiento lineal - reducir velocidad angular
        angularFactor = 0.3;
        break;
      case 'left':
      case 'right':
        // Giros - reducir velocidad lineal
        linearFactor = 0.5;
        break;
      case 'rotate_left':
      case 'rotate_right':
        // Rotación en lugar - solo velocidad angular
        linearFactor = 0.0;
        break;
    }

    return {
      'linear': baseLinear * linearFactor,
      'angular': baseAngular * angularFactor,
    };
  }

  // Generar secuencia de comandos para maniobras complejas
  static List<String> generateManeuverSequence(String maneuverType) {
    switch (maneuverType.toLowerCase()) {
      case 'turn_around':
        return [
          'ROTATE_LEFT:0.00:10.00',
          'ROTATE_LEFT:0.00:10.00',
          'STOP:0.00:0.00',
        ];
      case 'figure_eight':
        return [
          'MOVE_FORWARD:5.00:5.00',
          'TURN_LEFT:3.00:8.00',
          'TURN_LEFT:3.00:8.00',
          'TURN_RIGHT:3.00:8.00',
          'TURN_RIGHT:3.00:8.00',
          'STOP:0.00:0.00',
        ];
      case 'emergency_stop':
        return ['STOP:0.00:0.00', 'SOLENOID_OFF'];
      default:
        return ['STOP:0.00:0.00'];
    }
  }

  // Calcular tiempo estimado de movimiento
  static double estimateMovementTime(
    String direction,
    double distance,
    double velocity,
  ) {
    if (velocity <= 0) return 0.0;

    switch (direction) {
      case 'forward':
      case 'backward':
        return distance / velocity; // tiempo = distancia / velocidad
      case 'left':
      case 'right':
        // Para giros, distance sería el ángulo en radianes
        return distance / velocity;
      default:
        return 1.0; // Tiempo por defecto
    }
  }

  // Verificar si es seguro activar solenoide durante movimiento
  static bool isSafeToActivateSolenoidWhileMoving(
    String direction,
    double linearVel,
  ) {
    // No activar solenoide a alta velocidad
    if (linearVel > 15.0) return false;

    // Solo permitir en movimiento hacia adelante o parado
    return direction == 'forward' || direction == '' || linearVel == 0.0;
  }

  // Generar comando de calibración
  static List<String> generateCalibrationSequence() {
    return [
      'CALIBRATE_START',
      'MOVE_FORWARD:5.00:0.00',
      'STOP:0.00:0.00',
      'MOVE_BACKWARD:5.00:0.00',
      'STOP:0.00:0.00',
      'TURN_LEFT:0.00:5.00',
      'STOP:0.00:0.00',
      'TURN_RIGHT:0.00:5.00',
      'STOP:0.00:0.00',
      'SOLENOID_ON',
      'SOLENOID_OFF',
      'CALIBRATE_END',
    ];
  }

  // Validar parámetros de velocidad
  static bool validateVelocityParameters(double linear, double angular) {
    const double maxLinear = 50.0;
    const double maxAngular = 20.0;
    const double minVelocity = 0.0;

    return linear >= minVelocity &&
        linear <= maxLinear &&
        angular >= minVelocity &&
        angular <= maxAngular;
  }

  // Generar comando de diagnóstico
  static List<String> generateDiagnosticCommands() {
    return [
      'DIAGNOSTIC_START',
      'CHECK_MOTORS',
      'CHECK_SOLENOID',
      'CHECK_SENSORS',
      'CHECK_BATTERY',
      'DIAGNOSTIC_END',
    ];
  }

  // Calcular potencia necesaria para movimiento
  static double calculatePowerConsumption(
    String direction,
    double linearVel,
    double angularVel,
    bool solenoidActive,
  ) {
    double basePower = 0.0;

    // Potencia por movimiento lineal
    basePower += linearVel * 0.1; // Factor de potencia lineal

    // Potencia por movimiento angular
    basePower += angularVel * 0.15; // Factor de potencia angular

    // Potencia adicional del solenoide
    if (solenoidActive) {
      basePower += 2.0; // Potencia fija del solenoide
    }

    return basePower;
  }

  // Obtener recomendaciones de uso
  static List<String> getUsageRecommendations(
    double avgLinearVel,
    double avgAngularVel,
    int solenoidUsageCount,
  ) {
    List<String> recommendations = [];

    if (avgLinearVel > 20.0) {
      recommendations.add(
        'Velocidad lineal promedio alta - considera reducirla para mayor precisión',
      );
    }

    if (avgAngularVel > 15.0) {
      recommendations.add(
        'Muchos giros rápidos - puede causar desgaste en los motores',
      );
    }

    if (solenoidUsageCount > 100) {
      recommendations.add(
        'Uso intensivo del solenoide - verifica el nivel de agua',
      );
    }

    if (avgLinearVel < 2.0 && avgAngularVel < 2.0) {
      recommendations.add(
        'Velocidades muy bajas - puedes incrementarlas para mayor eficiencia',
      );
    }

    return recommendations;
  }
}
