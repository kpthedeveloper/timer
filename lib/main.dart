import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/timer_home_page.dart';
import 'providers/timer_provider.dart';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerProvider(),
      child: MaterialApp(
        title: 'Timer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const TimerHomePage(),
      ),
    );
  }
}
