import 'package:carsharing_kursach/features/main_feature%20copy/presentation/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable переменные
  final RxBool isRegister = false.obs;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Слушаем изменения состояния аутентификации
    user.bindStream(_auth.authStateChanges());
    ever(user, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      Get.offAll(() => MainScreen());
    }
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  // Регистрация нового пользователя
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (password != confirmPassword) {
        errorMessage.value = 'Пароли не совпадают';
        _showSnackbar('Ошибка', errorMessage.value, isError: true);
        return;
      }

      // Создаем пользователя в Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Пытаемся создать документ пользователя в Firestore
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Ошибка при создании документа пользователя: $e');
      }

      _showSnackbar('Успех', 'Регистрация успешно завершена');
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      _showSnackbar('Ошибка', errorMessage.value, isError: true);
    } catch (e) {
      print('Ошибка при регистрации: $e');
      errorMessage.value = 'Произошла неизвестная ошибка';
      _showSnackbar('Ошибка', errorMessage.value, isError: true);
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
      _showSnackbar('Успех', 'Вход выполнен успешно');
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      _showSnackbar('Ошибка', errorMessage.value, isError: true);
    } catch (e) {
      print('Ошибка при входе: $e');
      errorMessage.value = 'Произошла неизвестная ошибка';
      _showSnackbar('Ошибка', errorMessage.value, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Выход пользователя
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _showSnackbar('Успех', 'Выход выполнен успешно');
    } catch (e) {
      errorMessage.value = 'Ошибка при выходе из системы';
      _showSnackbar('Ошибка', errorMessage.value, isError: true);
    }
  }

  // Сброс пароля
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackbar(
        'Успех',
        'Инструкции по сбросу пароля отправлены на ваш email',
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthErrorMessage(e.code);
      _showSnackbar('Ошибка', errorMessage.value, isError: true);
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
        _showSnackbar('Успех', 'Данные успешно обновлены');
      }
    } catch (e) {
      errorMessage.value = 'Ошибка при обновлении данных';
      _showSnackbar('Ошибка', errorMessage.value, isError: true);
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
