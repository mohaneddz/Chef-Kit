import 'package:chefkit/blocs/inventory/inventory_bloc.dart';
import 'package:chefkit/views/screens/home_page.dart';
import 'package:chefkit/views/screens/login_page.dart';
import 'package:chefkit/views/screens/singup_page.dart';
// import 'package:chefkit/views/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => InventoryBloc())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: "Poppins"),
        home: SingupPage(),
      ),
    );
  }
}
