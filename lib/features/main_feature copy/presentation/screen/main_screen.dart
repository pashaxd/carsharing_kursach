import 'package:carsharing_kursach/features/main_feature%20copy/data/car_info_model.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/presentation/controller/main_controller.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/presentation/widgets/car_info_bottom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carsharing_kursach/features/main_feature copy/presentation/controller/map_controller.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  final MainController mainController = Get.put(MainController());
  final MapController mapController = Get.put(MapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              markers: Set.from(mainController.markers),
              onMapCreated: mapController.onMapCreated,
              initialCameraPosition: mapController.initialCameraPosition.value,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
            ),
          ),
        ],
      ),
    );
  }
}
