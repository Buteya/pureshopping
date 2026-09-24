import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isTextObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'pure shopping',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextFormField(
                  controller: email,
                  decoration: InputDecoration(labelText: "email"),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a email';
                    }
                    if (!value.contains("@")) {
                      return 'please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextFormField(
                  obscureText: isTextObscure,
                  controller: password,
                  decoration: InputDecoration(
                    labelText: "password",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isTextObscure = !isTextObscure;
                        });
                      },
                      icon: Icon(Icons.remove_red_eye_rounded),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!value.contains(
                      RegExp(
                        r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$',
                      ),
                    )) {
                      return 'password should contain at least one of these A-a 0-9 @ \$ ! % * ? &';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom:8.0),
                child: ElevatedButton(onPressed: () {}, child: Text("login")),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom:8.0),
                child: TextButton(onPressed: (){
                  Navigator.pushNamed(context, '/SignupScreen');
                }, child: Text('signup')),
              ),
              TextButton(onPressed: (){}, child: Text('forgot password?')),
            ],
          ),
        ),
      ),
    );
  }
}
