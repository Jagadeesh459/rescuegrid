import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'state/rescue_scope.dart';
import 'state/rescue_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RescueGridApp());
}

class RescueGridApp extends StatefulWidget {
  const RescueGridApp({super.key});

  @override
  State<RescueGridApp> createState() => _RescueGridAppState();
}

class _RescueGridAppState extends State<RescueGridApp> {
  late final RescueGridState _state;

  @override
  void initState() {
    super.initState();
    _state = RescueGridState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RescueScope(
      state: _state,
      child: MaterialApp(
        title: 'RescueGrid — Campus Emergency Response',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

