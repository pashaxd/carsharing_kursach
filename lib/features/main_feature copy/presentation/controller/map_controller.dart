import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carsharing_kursach/services/location_service.dart';

class MapController extends GetxController {
  final LocationService locationService = Get.find<LocationService>();
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final Rx<CameraPosition> initialCameraPosition = Rx<CameraPosition>(
    const CameraPosition(
      target: LatLng(53.906182, 27.558769), // Москва по умолчанию
      zoom: 10,
    ),
  );

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      await locationService.getCurrentLocation();
      if (locationService.currentPosition.value != null) {
        final position = locationService.currentPosition.value!;
        final cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        );

        initialCameraPosition.value = cameraPosition;

        if (mapController.value != null) {
          mapController.value!.animateCamera(
            CameraUpdate.newCameraPosition(cameraPosition),
          );
        }
      }
    } catch (e) {
      print('Ошибка получения местоположения: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
    getCurrentLocation();
  }
}
