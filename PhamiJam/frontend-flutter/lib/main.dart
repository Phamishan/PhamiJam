import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/state/app_state.dart';
import 'package:phamijam/pages/login.dart';
import 'package:phamijam/models/playback_model.dart';
import 'package:phamijam/controllers/user.dart';
import 'package:phamijam/client.dart';
import 'package:phamijam/prefs.dart';
import 'package:phamijam/models/songlist_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SecurePrefs.loadPrefs();
  final client = Client();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (_) => PlaybackModel()),
        ChangeNotifierProvider(create: (_) => SongListModel()),
        ChangeNotifierProvider(
          create: (_) => UserController(client: client, prefs: prefs),
        ),
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
