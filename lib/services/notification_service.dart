import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Configuração para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração para iOS/macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    // Configuração para Linux
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    // Inicializa o plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notificação local clicada: ${details.payload}');
      },
    );

    // Configuração do Firebase Messaging (apenas se suportado)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugPrint(
        'Firebase Messaging não suportado nativamente no Windows/Linux Desktop. Notificações remotas não funcionarão neste modo.',
      );
      return;
    }

    try {
      await _setupFirebaseMessaging();
    } catch (e) {
      debugPrint('Erro ao configurar Firebase Messaging: $e');
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicita permissão
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Permissão de usuário: ${settings.authorizationStatus}');

    // Handler para mensagens em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensagem recebida em primeiro plano: ${message.data}');
      
      if (message.notification != null) {
        debugPrint(
            'Mensagem também contém notificação: ${message.notification!.title}');
        
        showLocalNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'Nova Notificação',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Obter e imprimir o token FCM
    _getAndPrintFCMToken();
  }

  void _getAndPrintFCMToken() async   {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('================================================================');
    debugPrint('TOKEN FCM DO DISPOSITIVO: $token');
    debugPrint('================================================================');

    // Ouve por atualizações do token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('O token FCM foi atualizado: $newToken');
    });
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
