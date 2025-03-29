import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late FirebaseMessaging messaging;

  FirebaseMessaging get fcm => messaging;

  Future<FirebaseService> init() async {
    try {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      storage = FirebaseStorage.instance;
      messaging = FirebaseMessaging.instance;

      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      await initializeMessaging();

      debugPrint('🔥 Firebase Services Initialized');
      return this;
    } catch (e) {
      debugPrint('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  Future<void> initializeMessaging() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
    });

    String? token = await messaging.getToken();
    debugPrint('FCM Token: $token');

    auth.authStateChanges().listen((User? user) {
      if (user != null && token != null) {
        firestore
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token})
            .then((_) => debugPrint('FCM Token saved'))
            .catchError((error) => debugPrint('Failed to save FCM token: $error'));
      }
    });
  }

  Future<String> uploadImage(String path, Uint8List fileBytes) async {
    try {
      final ref = storage.ref().child(path);
      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }

  Future<String?> getCurrentUserId() async {
    return auth.currentUser?.uid;
  }

  bool isUserLoggedIn() {
    return auth.currentUser != null;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
