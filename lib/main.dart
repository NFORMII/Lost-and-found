import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import './appbar.dart';
import 'navigation/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  runApp(const LAFApp());
}

class LAFApp extends StatelessWidget {
  const LAFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LAF',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
      ),
      home: const MainNavigationWrapper(),
    );
  }
}
