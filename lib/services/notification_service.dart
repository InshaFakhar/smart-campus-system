import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ─────────────────────────────────────────────────────────────
//  Background message handler — must be top-level function
// ─────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.saveNotificationToHistory(message);
}

// ─────────────────────────────────────────────────────────────
//  Notification Model
// ─────────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;   // campus_updates | schedule_reminders | map_alerts | general
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id':      id,
    'title':   title,
    'body':    body,
    'type':    type,
    'time':    time.toIso8601String(),
    'isRead':  isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id:      j['id'],
    title:   j['title'],
    body:    j['body'],
    type:    j['type'] ?? 'general',
    time:    DateTime.parse(j['time']),
    isRead:  j['isRead'] ?? false,
  );
}

// ─────────────────────────────────────────────────────────────
//  Notification Service — Singleton
// ─────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging          _fcm   = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  // SharedPreferences keys
  static const _kHistory      = 'notif_history';
  static const _kCampus       = 'pref_campus_updates';
  static const _kSchedule     = 'pref_schedule_reminders';
  static const _kMapAlerts    = 'pref_map_alerts';
  static const _kAllNotifs    = 'pref_all_notifications';

  // ── Initialize ────────────────────────────────────────────
  Future<void> initialize() async {
    // 1. Request permission
    await _fcm.requestPermission(
      alert: true, badge: true, sound: true,
      provisional: false,
    );

    // 2. Local notifications setup
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    // 3. Android notification channel
    const channel = AndroidNotificationChannel(
      'uog_campus_channel',
      'UOG Campus Notifications',
      description: 'Smart Campus alerts and updates',
      importance: Importance.high,
      playSound: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Subscribe to saved topic preferences
    await _applySavedTopics();

    // 5. Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 6. Background/terminated tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    // 7. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 8. Check if app was opened from terminated notification
    final initial = await _fcm.getInitialMessage();
    if (initial != null) await saveNotificationToHistory(initial);
  }

  // ── Foreground Message ────────────────────────────────────
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    await saveNotificationToHistory(message);
    _showLocalNotification(message);
  }

  // ── Show Local Notification ───────────────────────────────
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'uog_campus_channel',
          'UOG Campus Notifications',
          channelDescription: 'Smart Campus alerts and updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF7C6FE8),
          styleInformation: BigTextStyleInformation(notification.body ?? ''),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalTap(NotificationResponse response) {
    // Navigate if needed — add navigation logic here
  }

  void _onNotificationTap(RemoteMessage message) {
    // Handle navigation when notification tapped from background
  }

  // ── Save to History (SharedPreferences) ──────────────────
  Future<void> saveNotificationToHistory(RemoteMessage message) async {
    final prefs   = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_kHistory) ?? [];

    final notif = AppNotification(
      id:    message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? 'Campus Update',
      body:  message.notification?.body  ?? message.data['body']  ?? '',
      type:  message.data['type'] ?? 'general',
      time:  DateTime.now(),
    );

    rawList.insert(0, jsonEncode(notif.toJson()));

    // Keep only last 50
    final trimmed = rawList.take(50).toList();
    await prefs.setStringList(_kHistory, trimmed);
  }

  // ── Load History ──────────────────────────────────────────
  Future<List<AppNotification>> loadHistory() async {
    final prefs   = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_kHistory) ?? [];
    return rawList
        .map((s) => AppNotification.fromJson(jsonDecode(s)))
        .toList();
  }

  // ── Mark All Read ─────────────────────────────────────────
  Future<void> markAllRead() async {
    final prefs   = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_kHistory) ?? [];
    final updated = rawList.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      map['isRead'] = true;
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_kHistory, updated);
  }

  // ── Unread Count ──────────────────────────────────────────
  Future<int> unreadCount() async {
    final list = await loadHistory();
    return list.where((n) => !n.isRead).length;
  }

  // ── Clear History ─────────────────────────────────────────
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHistory);
  }

  // ─────────────────────────────────────────────────────────
  //  Topic Subscription Management (Profile Toggles)
  // ─────────────────────────────────────────────────────────

  Future<void> _applySavedTopics() async {
    final prefs = await SharedPreferences.getInstance();

    final all      = prefs.getBool(_kAllNotifs)  ?? true;
    final campus   = prefs.getBool(_kCampus)     ?? true;
    final schedule = prefs.getBool(_kSchedule)   ?? true;
    final mapAlert = prefs.getBool(_kMapAlerts)  ?? false;

    // Always subscribe/unsubscribe based on saved prefs
    if (all) {
      if (campus)   await _fcm.subscribeToTopic('campus_updates');
      else          await _fcm.unsubscribeFromTopic('campus_updates');

      if (schedule) await _fcm.subscribeToTopic('schedule_reminders');
      else          await _fcm.unsubscribeFromTopic('schedule_reminders');

      if (mapAlert) await _fcm.subscribeToTopic('map_alerts');
      else          await _fcm.unsubscribeFromTopic('map_alerts');

      await _fcm.subscribeToTopic('general');
    } else {
      // All notifications OFF — unsubscribe everything
      await _fcm.unsubscribeFromTopic('campus_updates');
      await _fcm.unsubscribeFromTopic('schedule_reminders');
      await _fcm.unsubscribeFromTopic('map_alerts');
      await _fcm.unsubscribeFromTopic('general');
    }
  }

  // ── Toggle: All Notifications ─────────────────────────────
  Future<void> setAllNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAllNotifs, enabled);
    await _applySavedTopics();
  }

  // ── Toggle: Campus Updates ────────────────────────────────
  Future<void> setCampusUpdates(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCampus, enabled);
    await _applySavedTopics();
  }

  // ── Toggle: Schedule Reminders ────────────────────────────
  Future<void> setScheduleReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSchedule, enabled);
    await _applySavedTopics();
  }

  // ── Toggle: Map Alerts ────────────────────────────────────
  Future<void> setMapAlerts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMapAlerts, enabled);
    await _applySavedTopics();
  }

  // ── Load Saved Prefs ──────────────────────────────────────
  Future<Map<String, bool>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'all':      prefs.getBool(_kAllNotifs)  ?? true,
      'campus':   prefs.getBool(_kCampus)     ?? true,
      'schedule': prefs.getBool(_kSchedule)   ?? true,
      'mapAlerts':prefs.getBool(_kMapAlerts)  ?? false,
    };
  }

  // ── FCM Token (for direct messages) ──────────────────────
  Future<String?> getToken() async => await _fcm.getToken();
}