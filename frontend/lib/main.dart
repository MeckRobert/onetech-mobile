import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'widgets/styles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system navigation/status bar overlay styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF141416),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const OneTechApp());
}

class OneTechApp extends StatelessWidget {
  const OneTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ONETECH',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppStyles.accentGold,
        scaffoldBackgroundColor: AppStyles.background,
        colorScheme: ColorScheme.dark(
          primary: AppStyles.accentGold,
          secondary: AppStyles.accentGoldLight,
          background: AppStyles.background,
          surface: AppStyles.cardBg,
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
