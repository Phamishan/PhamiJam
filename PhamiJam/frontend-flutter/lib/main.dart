import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/state/app_state.dart';
import 'package:phamijam/pages/login.dart';
import 'package:phamijam/models/playback_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (_) => PlaybackModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhamiJam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFdba43a)),
        fontFamily: "Lexend",
      ),
      home: const Login(),
    );
  }
}
