import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoading = false.obs;

  Future<LocationService> init() async {
    return this;
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      // Проверяем разрешения
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Служба геолокации отключена');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Разрешение на геолокацию отклонено');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Разрешение на геолокацию отклонено навсегда');
      }

      // Получаем текущую позицию с высоким уровнем точности
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 5),
      );

      // Проверяем, что координаты находятся в разумных пределах для Беларуси

      currentPosition.value = position;
    } catch (e) {
      print('Ошибка получения местоположения: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
