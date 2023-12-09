import 'package:flutter/material.dart';
import 'package:mnp1/config/app_theme.dart';
import 'package:mnp1/config/providers/database_provider.dart';
import 'package:mnp1/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => DatabaseProvider()),
        // Agrega más providers según sea necesario
        // ChangeNotifierProvider(create: (context) => EstablishmentsProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme(selectedColor: 1).getTheme(),
        navigatorKey: AppConstants.globalNavKey,
        debugShowCheckedModeBanner: false,
        home: const Splash(),
      ),
    );
  }
}
