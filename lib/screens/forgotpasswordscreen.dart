import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pureshopping/models/user.dart';
import 'package:sqflite/sqflite.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool isTextObscure = true;
  bool isTextObscure1 = true;
  bool isLoading = false;

  void updatePassword(
    String email,
    String confirmPassword,
    BuildContext context,
  ) async {
    try {
      final db = await openDatabase(
        join(await getDatabasesPath(), 'pureshopping.db'),
        version: 1,
      );
      final userList = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      print('all users with email $email: $userList');
      if (userList.firstWhere((user) => user['email'] == email)['email'] ==
          email) {
        print(
          'user $email found: ${userList.firstWhere((user) => user['email'] == email)['email'] == email}',
        );
        User user = User(
          id: userList[0]['id'].toString(),
          firstname: userList[0]['firstname'].toString(),
          lastname: userList[0]['lastname'].toString(),
          email: userList[0]['email'].toString(),
          password: confirmPassword,
          userImage: userList[0]['userImage'].toString(),
        );
        print('$email updated password $confirmPassword:${user.toString()}');
        try {
          user.updateUser(user);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('user $email password updated successfully'),
            ),
          );
        }
        print(
          'updated $email successfully: ${userList.firstWhere((user) => user['email'] == email)}',
        );
        print(
          'all users with email $email: ${await db.query('users', where: 'email = ?', whereArgs: [email])}',
        );
        if(context.mounted){
          Navigator.pushNamed(context, '/LoginScreen');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('user $email not found')));
        }
      }
    } on StateError {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('user $email not found')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:isLoading?Center(child: CircularProgressIndicator(),): Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'forgot password',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
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
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextFormField(
                  obscureText: isTextObscure1,
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: "confirm password",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isTextObscure1 = !isTextObscure1;
                        });
                      },
                      icon: Icon(Icons.remove_red_eye_rounded),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a confirm password';
                    }
                    if (value != password.text) {
                      return 'passwords should match';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    formKey.currentState!.validate();
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      updatePassword(email.text, confirmPassword.text, context);
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text('update'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/LoginScreen');
                  },
                  child: Text('login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
