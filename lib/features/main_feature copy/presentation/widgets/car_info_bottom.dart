import 'package:carsharing_kursach/features/main_feature%20copy/data/car_info_model.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/presentation/screen/trip_screen.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/presentation/controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarInfoBottom extends StatelessWidget {
  final CarInfoModel carInfo;
  const CarInfoBottom({super.key, required this.carInfo});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      width: double.infinity,
      height: 200,
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Image.network(carInfo.image),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carInfo.name,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Text(carInfo.description),
                SizedBox(height: 10),
                Text('Cost: ${carInfo.price}'),
                SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    onPressed: () {
                      controller.startTrip(carInfo);
                      Get.off(() => TripScreen(car: carInfo));
                    },
                    child: Text(
                      'Начать поездку',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
