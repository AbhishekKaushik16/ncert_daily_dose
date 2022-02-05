import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_app/provider/provider_file.dart';
import 'package:notes_app/screens/components/welcome_screen.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          await OpenFile.open(payload);
        }
      });


  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProviderState()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(displayColor: textColor, bodyColor: Colors.black),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: primaryColor,
            padding: EdgeInsets.all(defaultPadding),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: textFieldBorder,
          enabledBorder: textFieldBorder,
          focusedBorder: textFieldBorder,
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}
