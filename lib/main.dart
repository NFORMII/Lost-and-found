import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'navigation/main_navigation_wrapper.dart';

void main() async {
  //  framework is ready
  WidgetsFlutterBinding.ensureInitialized(); 

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const LAFApp());
}


class LAFApp extends StatelessWidget {
  const LAFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LAF',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.indigo),
      home: const MainNavigationWrapper(),
    );
  }
}
