import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pureshopping/screens/createproductscreen.dart';
import 'package:pureshopping/screens/forgotpasswordscreen.dart';
import 'package:pureshopping/screens/homescreen.dart';
import 'package:pureshopping/screens/loginscreen.dart';
import 'package:pureshopping/screens/productdashboardscreen.dart';
import 'package:pureshopping/screens/signupscreen.dart';
import 'package:pureshopping/screens/viewcartscreen.dart';
import 'package:pureshopping/screens/viewsingleproductscreen.dart';
import 'package:pureshopping/utility/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }else{
    databaseFactory = databaseFactoryFfi;
  }
  createDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/CreateProductScreen':(context) => CreateProductScreen(),
        '/ProductDashboardScreen': (context) => ProductDashboardScreen(),
        '/SignupScreen': (context) => SignupScreen(),
        '/LoginScreen': (context) => LoginScreen(),
        '/ForgotPasswordScreen' : (context) => ForgotPasswordScreen(),
        '/HomeScreen' : (context) => HomeScreen(),
        '/ViewCartScreen' : (context) => ViewCartScreen(),
        '/ViewSingleProductScreen' : (context) => ViewSingleProductScreen(),
      },
      title: 'pureshopping',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/LoginScreen',
    );
  }
}
