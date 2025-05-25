class CarInfoModel {
  final String name;
  final String image;
  final String description;
  final double price;
  final double locationY;
  final double locationX;

  CarInfoModel({
    required this.locationY,
    required this.locationX,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
  });
}
