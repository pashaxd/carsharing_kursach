import 'package:carsharing_kursach/features/auth_feature%20copy/presentation/controller/auth_controller.dart';
import 'package:carsharing_kursach/features/auth_feature%20copy/presentation/screen/auth_screen.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/presentation/screen/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carsharing_kursach/services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Инициализация сервисов
  await Get.putAsync(() => LocationService().init());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController? mapController;
  // Координаты центра Москвы
  final LatLng _center = const LatLng(53.895900, 27.557823);
  bool _isMapLoading = true;
  String? _errorMessage;

  void _onMapCreated(GoogleMapController controller) {
    try {
      setState(() {
        mapController = controller;
        _isMapLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка инициализации карты: $e';
        _isMapLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: GetBuilder<AuthController>(
        init: AuthController(),
        builder: (controller) {
          return Obx(
            () => controller.user.value != null ? MainScreen() : AuthScreen(),
          );
        },
      ),
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
