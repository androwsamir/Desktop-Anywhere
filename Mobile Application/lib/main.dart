import 'package:desktop_anywhere/modules/WelcomePage/WelcomePage.dart';
import 'package:desktop_anywhere/shared/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocProvider(create: (context) =>AppCubit()..createDatabase(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    ),
    );
  }
}

