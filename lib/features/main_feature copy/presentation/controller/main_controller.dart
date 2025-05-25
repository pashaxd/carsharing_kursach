import 'package:carsharing_kursach/features/main_feature%20copy/presentation/widgets/car_info_bottom.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/data/car_info_model.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/data/main_repo.dart';
import 'dart:async';

enum TripStatus { notStarted, inProgress, completed }

class MainController extends GetxController {
  final MainRepository _repository = MainRepository();

  // Observable переменные
  final RxList<CarInfoModel> cars = <CarInfoModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CarInfoModel?> selectedCar = Rx<CarInfoModel?>(null);
  final RxList<Marker> markers = <Marker>[].obs;
  final Rx<TripStatus> tripStatus = TripStatus.notStarted.obs;

  // Поля для таймера
  final RxBool isTimerRunning = false.obs;
  final RxInt seconds = 0.obs;
  Timer? _timer;

  // Геттер для форматированного времени
  String get formattedTime {
    final hours = (seconds.value ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds.value % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds.value % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  // Методы для управления таймером
  void startTimer() {
    if (!isTimerRunning.value) {
      isTimerRunning.value = true;
      tripStatus.value = TripStatus.inProgress;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        seconds.value++;
      });
    }
  }

  void stopTimer() {
    if (isTimerRunning.value) {
      isTimerRunning.value = false;
      tripStatus.value = TripStatus.completed;
      _timer?.cancel();
    }
  }

  void resetTimer() {
    stopTimer();
    seconds.value = 0;
    tripStatus.value = TripStatus.notStarted;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    loadCars();
  }

  void upateCarInfo(String name, double locationY, double locationX) {
    try {
      _repository.updateCar(name, locationY, locationX);
    } catch (e) {
      errorMessage.value = 'Ошибка при загрузке машин: $e';
      isLoading.value = false;
      update();
    }
  }

  // Загрузка всех машин
  void loadCars() {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    try {
      _repository.getCars().listen(
        (carsList) {
          cars.value = carsList;
          _updateMarkers(carsList);
          isLoading.value = false;
          update();
        },
        onError: (error) {
          errorMessage.value = 'Ошибка при загрузке машин: $error';
          isLoading.value = false;
          update();
        },
      );
    } catch (e) {
      errorMessage.value = 'Ошибка при загрузке машин: $e';
      isLoading.value = false;
      update();
    }
  }

  // Обновление маркеров на карте
  void _updateMarkers(List<CarInfoModel> carsList) {
    final Set<Marker> newMarkers = {};

    for (var car in carsList) {
      final marker = Marker(
        markerId: MarkerId(car.name),
        position: LatLng(car.locationY, car.locationX),
        infoWindow: InfoWindow(
          title: car.name,
          snippet: '${car.price} руб/час',
        ),
        onTap: () => selectCar(car),
      );
      newMarkers.add(marker);
    }

    markers.value = newMarkers.toList();
    update();
  }

  // Выбор машины
  void selectCar(CarInfoModel car) {
    selectedCar.value = car;
    Get.bottomSheet(CarInfoBottom(carInfo: car));
    update();
  }

  void startTrip(CarInfoModel car) {
    selectedCar.value = car;
    tripStatus.value = TripStatus.inProgress;
    startTimer();
  }
}
