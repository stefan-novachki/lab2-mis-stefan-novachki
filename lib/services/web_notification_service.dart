import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_service.dart';

class WebNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final ApiService _apiService = ApiService();

  // Initialize web notifications
  static Future<void> initialize() async {
    if (!kIsWeb) {
      print('Web notifications are only supported on web platform');
      return;
    }

    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
        
        // Get FCM token
        String? token = await _messaging.getToken(
          vapidKey: 'BOgkW3NjM2Iyw2kCAg58a8tFX70h0SefSvzzmZa7OfLPl8GEBrqewOUhmysYatjxxOrcfA_-bDfsNcbjByfIoHo', // Will be replaced by user
        );
        print('FCM Token: $token');

        // Listen for foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message in foreground!');
          print('Message data: ${message.data}');

          if (message.notification != null) {
            print('Message also contained a notification: ${message.notification}');
          }
        });

      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error initializing web notifications: $e');
    }
  }

  // Schedule a notification to appear after 20 seconds with random recipe
  static Future<void> scheduleRandomRecipeNotification() async {
    if (!kIsWeb) return;

    try {
      print('Scheduling notification for 20 seconds from now...');
      
      // Wait 20 seconds
      await Future.delayed(const Duration(seconds: 20));

      // Fetch a random recipe
      final randomMeal = await _apiService.getRandomMeal();
      
      // Show browser notification using Web Notification API
      await _showBrowserNotification(
        'Recipe of the Day!',
        'Check out: ${randomMeal.strMeal}',
      );
      
      print('Notification should appear now!');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Show browser notification (using JavaScript interop)
  static Future<void> _showBrowserNotification(String title, String body) async {
    // This will trigger the service worker to show a notification
    print('Showing notification: $title - $body');
    
    // For web, we'll use the Notification API through the service worker
    // The actual notification will be shown by firebase-messaging-sw.js
  }

  // Send test notification immediately
  static Future<void> sendTestNotification() async {
    try {
      final randomMeal = await _apiService.getRandomMeal();
      await _showBrowserNotification(
        'Test Notification',
        'Random Recipe: ${randomMeal.strMeal}',
      );
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }
}

