class RobotTestsLogic {
  // Mapeo de pruebas a comandos
  static const Map<String, String> _testCommands = {
    'forward': 'MOVE_FORWARD',
    'reverse': 'MOVE_BACKWARD',
    'right': 'TURN_RIGHT',
    'left': 'TURN_LEFT',
    'rotation': 'ROTATE_IN_PLACE',
    'solenoid_off': 'SOLENOID_OFF',
    'solenoid_on': 'SOLENOID_ON',
    'solenoid_motion': 'SOLENOID_MOTION',
  };

  // Descripción de cada prueba
  static const Map<String, String> _testDescriptions = {
    'forward': 'Movimiento hacia adelante completado',
    'reverse': 'Movimiento hacia atrás completado',
    'right': 'Giro a la derecha completado',
    'left': 'Giro a la izquierda completado',
    'rotation': 'Rotación en el lugar completada',
    'solenoid_off': 'Solenoide desactivado',
    'solenoid_on': 'Solenoide activado',
    'solenoid_motion': 'Solenoide activado en movimiento',
  };

  // Duración estimada de cada prueba (en segundos)
  static const Map<String, int> _testDurations = {
    'forward': 3,
    'reverse': 3,
    'right': 2,
    'left': 2,
    'rotation': 4,
    'solenoid_off': 1,
    'solenoid_on': 1,
    'solenoid_motion': 5,
  };

  // Obtener comando para una prueba específica
  static String getTestCommand(String testType) {
    return _testCommands[testType] ?? '';
  }

  // Obtener descripción de una prueba
  static String getTestDescription(String testType) {
    return _testDescriptions[testType] ?? 'Prueba completada';
  }

  // Obtener duración estimada de una prueba
  static int getTestDuration(String testType) {
    return _testDurations[testType] ?? 2;
  }

  // Validar que todas las pruebas de movimiento estén completas
  static bool validateMovementTests(Map<String, bool> tests) {
    List<String> requiredTests = [
      'forward',
      'reverse',
      'right',
      'left',
      'rotation',
    ];
    return requiredTests.every((test) => tests[test] == true);
  }

  // Validar que todas las pruebas de solenoide estén completas
  static bool validateSolenoidTests(Map<String, bool> tests) {
    List<String> requiredTests = ['off', 'on', 'motion'];
    return requiredTests.every((test) => tests[test] == true);
  }

  // Obtener lista de pruebas faltantes
  static List<String> getMissingTests(
    Map<String, bool> movementTests,
    Map<String, bool> solenoidTests,
  ) {
    List<String> missing = [];

    movementTests.forEach((key, value) {
      if (!value) {
        missing.add(_testDescriptions['$key'] ?? key);
      }
    });

    solenoidTests.forEach((key, value) {
      if (!value) {
        missing.add(_testDescriptions['solenoid_$key'] ?? key);
      }
    });

    return missing;
  }

  // Generar reporte de pruebas
  static String generateTestReport(
    Map<String, bool> movementTests,
    Map<String, bool> solenoidTests,
  ) {
    int totalTests = movementTests.length + solenoidTests.length;
    int completedTests = 0;

    completedTests += movementTests.values.where((test) => test).length;
    completedTests += solenoidTests.values.where((test) => test).length;

    double completionPercentage = (completedTests / totalTests) * 100;

    return 'Pruebas completadas: $completedTests/$totalTests (${completionPercentage.toStringAsFixed(1)}%)';
  }

  // Verificar si es seguro proceder a la configuración
  static bool isSafeToProceed(
    Map<String, bool> movementTests,
    Map<String, bool> solenoidTests,
  ) {
    // Todas las pruebas de movimiento básico deben estar completas
    List<String> criticalTests = ['forward', 'reverse'];
    bool criticalTestsPassed = criticalTests.every(
      (test) => movementTests[test] == true,
    );

    // Al menos una prueba de solenoide debe estar completa
    bool solenoidTested = solenoidTests.values.any((test) => test);

    return criticalTestsPassed && solenoidTested;
  }

  // Obtener recomendaciones basadas en pruebas completadas
  static List<String> getRecommendations(
    Map<String, bool> movementTests,
    Map<String, bool> solenoidTests,
  ) {
    List<String> recommendations = [];

    if (!movementTests['forward']!) {
      recommendations.add('Completar prueba de movimiento hacia adelante');
    }

    if (!movementTests['reverse']!) {
      recommendations.add('Completar prueba de movimiento hacia atrás');
    }

    if (!solenoidTests['off']! || !solenoidTests['on']!) {
      recommendations.add('Probar funcionamiento básico del solenoide');
    }

    if (!movementTests['rotation']!) {
      recommendations.add(
        'Probar rotación en el lugar para mejor maniobrabilidad',
      );
    }

    return recommendations;
  }
}
