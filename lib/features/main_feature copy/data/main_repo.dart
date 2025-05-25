import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carsharing_kursach/features/main_feature%20copy/data/car_info_model.dart';

class MainRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cars';

  // Получение всех машин
  Stream<List<CarInfoModel>> getCars() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CarInfoModel(
          name: data['name'] ?? '',
          image: data['image'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          locationX: (data['locationX'] ?? 0.0).toDouble(),
          locationY: (data['locationY'] ?? 0.0).toDouble(),
        );
      }).toList();
    });
  }

  // Получение машины по ID
  Future<CarInfoModel?> getCarById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        return CarInfoModel(
          name: data['name'] ?? '',
          image: data['image'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          locationX: (data['locationX'] ?? 0.0).toDouble(),
          locationY: (data['locationY'] ?? 0.0).toDouble(),
        );
      }
      return null;
    } catch (e) {
      print('Error getting car by id: $e');
      return null;
    }
  }

  // Добавление новой машины
  Future<void> addCar(CarInfoModel car) async {
    try {
      await _firestore.collection(_collection).add({
        'name': car.name,
        'image': car.image,
        'description': car.description,
        'price': car.price,
        'locationX': car.locationX,
        'locationY': car.locationY,
      });
    } catch (e) {
      print('Error adding car: $e');
      rethrow;
    }
  }

  // Обновление информации о машине
  Future<void> updateCar(
    String name,
    double locationX,
    double locationY,
  ) async {
    try {
      await _firestore.collection(_collection).doc(name).update({
        'locationX': locationX,
        'locationY': locationY,
      });
    } catch (e) {
      print('Error updating car: $e');
      rethrow;
    }
  }

  // Удаление машины
  Future<void> deleteCar(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting car: $e');
      rethrow;
    }
  }
}
