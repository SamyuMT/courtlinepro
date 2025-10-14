import 'package:get/get.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/bluetooth_connection_page.dart';
import '../ui/pages/robot_tests_page.dart';
import '../ui/pages/robot_config_page.dart';
import '../ui/pages/manual_control_page.dart';
import '../ui/pages/serial_console_page.dart';
import '../bindings/home_binding.dart';
import '../bindings/bluetooth_binding.dart';
import '../bindings/robot_tests_binding.dart';
import '../bindings/robot_config_binding.dart';
import '../bindings/manual_control_binding.dart';
import '../bindings/serial_console_binding.dart';

class AppRoutes {
  static const String home = '/';
  static const String bluetoothConnection = '/conexionbt';
  static const String robotTests = '/pruebasrobot';
  static const String robotConfig = '/configuracionrobot';
  static const String manualControl = '/mandocontrol';
  static const String serialConsole = '/serialconsole';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.bluetoothConnection,
      page: () => const BluetoothConnectionPage(),
      binding: BluetoothBinding(),
    ),
    GetPage(
      name: AppRoutes.robotTests,
      page: () => const RobotTestsPage(),
      binding: RobotTestsBinding(),
    ),
    GetPage(
      name: AppRoutes.robotConfig,
      page: () => const RobotConfigPage(),
      binding: RobotConfigBinding(),
    ),
    GetPage(
      name: AppRoutes.manualControl,
      page: () => const ManualControlPage(),
      binding: ManualControlBinding(),
    ),
    GetPage(
      name: AppRoutes.serialConsole,
      page: () => const SerialConsolePage(),
      binding: SerialConsoleBinding(),
    ),
  ];
}
