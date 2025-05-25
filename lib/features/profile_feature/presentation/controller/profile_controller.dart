import 'package:get/get.dart';
import 'package:carsharing_kursach/features/profile_feature/data/trip_history_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<TripHistoryModel> tripHistory = <TripHistoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble totalBalance = 0.1.obs;

  @override
  void onInit() {
    super.onInit();
    loadTripHistory();
    loadBalance();
  }

  Future<void> loadBalance() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        totalBalance.value = doc.data()?['balance'] ?? 0;
      } else {
        doc.reference.set({'balance': totalBalance.value});
      }
    } catch (e) {
      errorMessage.value = 'Ошибка при загрузке баланса: $e';
    }
  }

  Future<void> loadTripHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Пользователь не авторизован';
        return;
      }

      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('trips')
              .orderBy('timestamp', descending: true)
              .get();

      tripHistory.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return TripHistoryModel(
              carName: data['carName'] ?? '',
              carImage: data['carImage'] ?? '',
              price: (data['price'] ?? 0.0).toDouble(),
              duration: data['duration'] ?? 0,
            );
          }).toList();

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Ошибка при загрузке истории поездок: $e';
      isLoading.value = false;
    }
  }

  Future<void> addTrip(TripHistoryModel trip) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Пользователь не авторизован';
        return;
      }

      // Добавляем поездку
      await _firestore.collection('users').doc(userId).collection('trips').add({
        'carName': trip.carName,
        'carImage': trip.carImage,
        'price': trip.price,
        'duration': trip.duration,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Обновляем баланс
      updateBalance(totalBalance.value - trip.totalCost);

      // Обновляем данные
      await loadTripHistory();
      await loadBalance();
    } catch (e) {
      errorMessage.value = 'Ошибка при добавлении поездки: $e';
    }
  }

  Future<void> updateBalance(double amount) async {
    final userId = _auth.currentUser?.uid;
    try {
      await _firestore.collection('users').doc(userId).update({
        'balance': amount,
      });
      totalBalance.value = amount;
    } catch (e) {
      errorMessage.value = 'Ошибка при обновлении баланса: $e';
    }
  }

  Future<void> deleteTripHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'Пользователь не авторизован';
        return;
      }

      // Получаем все документы в коллекции trips
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('trips')
              .get();

      // Удаляем каждый документ
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Выполняем пакетное удаление
      await batch.commit();

      // Сбрасываем баланс
      await _firestore.collection('users').doc(userId).update({'balance': 0});

      // Очищаем локальные данные
      tripHistory.clear();
      totalBalance.value = 0;

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Ошибка при удалении истории поездок: $e';
      isLoading.value = false;
    }
  }
}
