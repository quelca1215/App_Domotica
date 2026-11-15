import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/home_automation_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación vertical para una experiencia consistente
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const DomoticaApp());
}

class DomoticaApp extends StatelessWidget {
  const DomoticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeAutomationProvider()..initialize(),
      child: MaterialApp(
        title: 'DomoHouse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0F1D),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF38BDF8),
            secondary: Color(0xFF10B981),
            surface: Color(0xFF1E293B),
          ),
          fontFamily: null, // Usa la tipografía predeterminada del sistema
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
