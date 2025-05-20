import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable переменные
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Слушаем изменения состояния аутентификации
    user.bindStream(_auth.authStateChanges());
  }

  // Регистрация нового пользователя
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Создаем пользователя в Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Создаем документ пользователя в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
      });

      Get.snackbar(
        'Успех',
        'Регистрация успешно завершена',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      Get.snackbar(
        'Ошибка',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Произошла неизвестная ошибка';
      Get.snackbar(
        'Ошибка',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Вход пользователя
  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Get.snackbar(
        'Успех',
        'Вход выполнен успешно',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      Get.snackbar(
        'Ошибка',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Произошла неизвестная ошибка';
      Get.snackbar(
        'Ошибка',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Выход пользователя
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.snackbar(
        'Успех',
        'Выход выполнен успешно',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Ошибка при выходе из системы';
      Get.snackbar(
        'Ошибка',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Сброс пароля
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Успех',
        'Инструкции по сбросу пароля отправлены на ваш email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      Get.snackbar(
        'Ошибка',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Получение данных текущего пользователя
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (user.value != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.value!.uid).get();
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      errorMessage.value = 'Ошибка при получении данных пользователя';
      return null;
    }
  }

  // Обновление данных пользователя
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (user.value != null) {
        await _firestore.collection('users').doc(user.value!.uid).update(data);
        Get.snackbar(
          'Успех',
          'Данные успешно обновлены',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Ошибка при обновлении данных';
      Get.snackbar(
        'Ошибка',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Проверка, авторизован ли пользователь
  bool get isAuthenticated => user.value != null;

  // Получение сообщения об ошибке на основе кода ошибки Firebase
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'weak-password':
        return 'Пароль слишком слабый';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Пользователь отключен';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      default:
        return 'Произошла ошибка при аутентификации';
    }
  }
}
