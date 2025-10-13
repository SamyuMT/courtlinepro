# CourtLine Pro - Robot Control App

Una aplicación Flutter para el control de robots a través de Bluetooth, diseñada específicamente para el robot CourtLine Pro.

## 📱 Características

- **Conexión Bluetooth**: Búsqueda y conexión a dispositivos BLE
- **Pruebas del Robot**: Sistema de checklist para validar funcionamiento
- **Configuración de Velocidades**: Control de velocidad lineal y angular
- **Control Manual**: Interface táctil para manejo directo del robot
- **Control de Solenoide**: Activación/desactivación de válvulas

## 🏗️ Arquitectura

La aplicación utiliza el patrón **GetX** para el manejo de estado y navegación, con una arquitectura modular:

```
lib/
├── app/
│   ├── ui/
│   │   ├── pages/          # Páginas de la aplicación
│   │   └── themes/         # Temas, colores y estilos
│   ├── controllers/        # Controladores de estado (GetX)
│   ├── bindings/          # Bindings para inyección de dependencias
│   ├── logic/             # Lógica de negocio
│   └── routes/            # Configuración de rutas
├── main.dart              # Punto de entrada de la aplicación
└── app_exports.dart       # Exportaciones centralizadas
```

## 📄 Páginas

### 1. **HomePage** (`/`)
- Pantalla de inicio con botón START
- Navegación inicial hacia conexión Bluetooth

### 2. **BluetoothConnectionPage** (`/conexionbt`)
- Búsqueda de dispositivos BLE
- Lista de dispositivos disponibles
- Indicador de estado de conexión
- Botón para continuar a pruebas

### 3. **RobotTestsPage** (`/pruebasrobot`)
- **Pruebas de movimiento**:
  - Movimiento hacia adelante
  - Movimiento hacia atrás
  - Giro a la derecha
  - Giro a la izquierda
  - Rotación en el lugar
- **Pruebas de solenoide**:
  - Solenoide apagado
  - Solenoide encendido
  - Solenoide en movimiento
- Botón de reinicio de pruebas
- Navegación a configuración

### 4. **RobotConfigPage** (`/configuracionrobot`)
- Control de velocidad lineal (cm/s)
- Control de velocidad angular (rad/s)
- Botones de incremento/decremento
- Botón para probar cambios
- Navegación a control manual

### 5. **ManualControlPage** (`/mandocontrol`)
- **Controles de movimiento**:
  - Botones direccionales (adelante, atrás, izquierda, derecha)
  - Control táctil (presionar y mantener)
- **Indicadores de velocidad**:
  - Velocidad lineal actual
  - Velocidad angular actual
- **Controles adicionales**:
  - Velocímetro con control de intensidad
  - Botón de solenoide
  - Acceso a configuraciones

## 🎮 Controladores

### BluetoothController
- Gestión de conexión Bluetooth
- Búsqueda de dispositivos
- Envío de comandos al robot
- Monitoreo del estado de conexión

### RobotTestsController
- Ejecución de pruebas de movimiento
- Validación de funcionamiento del solenoide
- Seguimiento del progreso de pruebas
- Navegación condicional basada en pruebas completadas

### RobotConfigController
- Configuración de velocidades
- Validación de parámetros
- Envío de comandos de configuración
- Pruebas de configuración

### ManualControlController
- Control en tiempo real del robot
- Gestión de movimientos continuos
- Control del solenoide
- Ajuste dinámico de velocidades

## 🧠 Lógica de Negocio

### BluetoothLogic
- Validación de dispositivos Bluetooth
- Filtrado de dispositivos de robot
- Gestión de permisos
- Generación de comandos de prueba

### RobotTestsLogic
- Mapeo de pruebas a comandos
- Validación de completitud de pruebas
- Generación de reportes
- Recomendaciones de seguridad

### RobotConfigLogic
- Generación de comandos de configuración
- Validación de parámetros de velocidad
- Cálculo de configuraciones óptimas
- Ajustes por condiciones ambientales

### ManualControlLogic
- Generación de comandos de movimiento
- Cálculo de velocidades seguras
- Secuencias de maniobras complejas
- Validación de operaciones

## 🎨 Diseño y Tema

### Colores Principales
- **Primario**: Azul oscuro (`#1E3A5F`)
- **Secundario**: Azul medio (`#2D5A87`)
- **Acento**: Azul brillante (`#006BFF`)
- **Estados**: Verde (`#4CAF50`) para online, Rojo (`#F44336`) para offline

### Tipografía
- **Fuente principal**: Roboto
- **Títulos**: 48px, peso 800
- **Botones**: 20-64px según importancia
- **Texto de lista**: 16px, peso 400

## 🚀 Comandos del Robot

### Movimiento
```
MOVE_FORWARD:<vel_linear>:<vel_angular>
MOVE_BACKWARD:<vel_linear>:<vel_angular>
TURN_LEFT:<vel_linear>:<vel_angular>
TURN_RIGHT:<vel_linear>:<vel_angular>
ROTATE_LEFT:0.00:<vel_angular>
ROTATE_RIGHT:0.00:<vel_angular>
STOP:0.00:0.00
```

### Configuración
```
SET_LINEAR_VEL:<velocidad>
SET_ANGULAR_VEL:<velocidad>
CONFIG_START
CONFIG_END
CONFIG_APPLY
```

### Solenoide
```
SOLENOID_ON
SOLENOID_OFF
```

## 📦 Dependencias

- **get**: Manejo de estado y navegación
- **flutter_bluetooth_serial**: Conectividad Bluetooth
- **permission_handler**: Gestión de permisos

## 🔧 Instalación

1. Clonar el repositorio
2. Ejecutar `flutter pub get`
3. Configurar permisos de Bluetooth en `android/app/src/main/AndroidManifest.xml`
4. Ejecutar `flutter run`

## 📱 Flujo de Usuario

1. **Inicio** → Presionar START
2. **Conexión** → Buscar y conectar dispositivo Bluetooth
3. **Pruebas** → Completar checklist de funcionamiento
4. **Configuración** → Ajustar velocidades del robot
5. **Control** → Manejar robot manualmente

## 🔒 Consideraciones de Seguridad

- Validación de parámetros de velocidad
- Parada de emergencia
- Verificación de conexión antes de comandos
- Límites de velocidad configurables
- Indicadores visuales de estado

## 🎯 Futuras Mejoras

- [ ] Grabación de rutas automáticas
- [ ] Integración con cámara
- [ ] Telemetría avanzada
- [ ] Control por voz
- [ ] Mapeo del área de trabajo
- [ ] Modo automático de trabajo
