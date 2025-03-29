import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/data/models/user_model.dart';
import 'package:helpper/data/repositories/auth_repository.dart';
import 'package:helpper/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString verificationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authRepository.authStateChanges);
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      await _fetchUserData(user.uid);
      Get.offAllNamed(AppRoutes.HOME);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      isLoading.value = true;
      userModel.value = await _authRepository.getUserFromFirestore(uid);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authRepository.signInWithEmail(email, password);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> signUpWithEmail(String name, String email, String password, String phone, bool isProvider) async {
    try {
      isLoading.value = true;
      error.value = '';

      UserCredential userCredential = await _authRepository.signUpWithEmail(email, password);

      await _authRepository.createUserInFirestore(
        userCredential.user!,
        name,
        phone,
        isProvider,
      );

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      error.value = '';

      UserCredential userCredential = await _authRepository.signInWithGoogle();

      UserModel? user = await _authRepository.getUserFromFirestore(userCredential.user!.uid);

      if (user == null) {
        await _authRepository.createUserInFirestore(
          userCredential.user!,
          userCredential.user!.displayName ?? 'Usuário',
          userCredential.user!.phoneNumber ?? '',
          true,
        );
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> signInWithPhone(String phone) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authRepository.signInWithPhone(
        phone,
            (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
            (FirebaseAuthException e) {
          isLoading.value = false;
          error.value = e.message ?? 'Erro na verificação de telefone';
        },
            (String verId, int? resendToken) {
          verificationId.value = verId;
          isLoading.value = false;
          Get.toNamed(AppRoutes.VERIFICATION);
        },
            (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> verifyPhoneCode(String smsCode) async {
    try {
      isLoading.value = true;
      error.value = '';

      UserCredential userCredential = await _authRepository.verifyPhoneCode(
        verificationId.value,
        smsCode,
      );

      UserModel? user = await _authRepository.getUserFromFirestore(userCredential.user!.uid);

      if (user == null) {
        await _authRepository.createUserInFirestore(
          userCredential.user!,
          userCredential.user!.displayName ?? 'Usuário',
          userCredential.user!.phoneNumber ?? '',
          true,
        );
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authRepository.resetPassword(email);

      isLoading.value = false;
      Get.snackbar(
        'Sucesso',
        'Email de redefinição de senha enviado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authRepository.updateUserProfile(firebaseUser.value!.uid, data);

      await _fetchUserData(firebaseUser.value!.uid);

      isLoading.value = false;
      Get.snackbar(
        'Sucesso',
        'Perfil atualizado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }
}
