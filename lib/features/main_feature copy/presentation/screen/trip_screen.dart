import 'package:carsharing_kursach/features/main_feature%20copy/data/car_info_model.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/presentation/controller/main_controller.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/presentation/screen/main_screen.dart';
import 'package:carsharing_kursach/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripScreen extends StatelessWidget {
  final CarInfoModel car;
  TripScreen({super.key, required this.car});
  final LocationService locationService = Get.find<LocationService>();
  final MainController tripController = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            car.name,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Image.network(car.image),
          // Таймер
          Container(
            padding: const EdgeInsets.all(20),
            child: Obx(
              () => Column(
                children: [
                  Text(
                    tripController.formattedTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      tripController.isTimerRunning.value
                          ? ElevatedButton(
                            onPressed: () {
                              if (tripController.isTimerRunning.value) {
                                tripController.stopTimer();
                              } else {
                                tripController.startTimer();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,

                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: Text(
                              'finish trip',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          )
                          : Obx(
                            () => GestureDetector(
                              onTap: () {
                                if (locationService.currentPosition.value !=
                                    null) {
                                  final position =
                                      locationService.currentPosition.value!;
                                  tripController.upateCarInfo(
                                    car.name,
                                    position.longitude,
                                    position.latitude,
                                  );
                                }
                                Get.off(MainScreen());
                              },
                              child: Container(
                                width: 200,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    'total: ${tripController.seconds * car.price}\$',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
