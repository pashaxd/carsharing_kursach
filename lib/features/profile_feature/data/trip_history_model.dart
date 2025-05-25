class TripHistoryModel {
  final String carName;
  final String carImage;
  final double price;
  final int duration; // в секундах

  TripHistoryModel({
    required this.carName,
    required this.carImage,
    required this.price,
    required this.duration,
  });

  // Форматированное время поездки
  String get formattedDuration {
    final hours = (duration ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((duration % 3600) ~/ 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  // Общая стоимость поездки
  double get totalCost => duration * price;
}
