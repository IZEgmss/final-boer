import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Feature 6
// Feature 6
import 'package:finalboer/providers/cart_provider.dart';
import 'package:finalboer/screens/list_products.dart'; // Importe a tela renomeada
import 'package:finalboer/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA3jgXc_5Uz3w_RWSzGRVLpyjuVewniko8",
        appId: "1:109289610484:web:291e6e645200ad46c292a1",
        messagingSenderId: "109289610484",
        projectId: "finalboer-3bb5d",
        authDomain: "finalboer-3bb5d.firebaseapp.com",
      ),
    );
  } catch (e) {
    debugPrint("Erro ao inicializar Firebase: $e");
  }

  // Inicializar Serviço de Notificações (Local + FCM)
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuração do Provider no topo da árvore
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: MaterialApp(
        title: 'Loja Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.blue.withValues(alpha: 0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}
