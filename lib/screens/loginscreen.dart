import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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

  void login(String email, String password, BuildContext context) async {
    try {
      SharedPreferencesWithCache prefsWithCache =
          await SharedPreferencesWithCache.create(
            cacheOptions: const SharedPreferencesWithCacheOptions(
              allowList: <String>{
                'currentUserId',
                'email',
                'userImage',
                'currentCartItems',
              },
            ),
          );

      final db = await openDatabase(
        join(await getDatabasesPath(), 'pureshopping.db'),
        version: 1,
      );
      print(
        'list of all users with email, $email : ${await db.query('users', where: 'email = ?', whereArgs: [email])}',
      );
      final user = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (user.firstWhere((user) => user['email'] == email)['password'] ==
          password) {
        print(
          'the password associated with email, $email: ${user.firstWhere((user) => user['email'] == email)['password']}',
        );
        print(
          'is the password equal to $password : ${user.firstWhere((user) => user['email'] == email)['password'] == password}',
        );
        final loggedInUser = user.firstWhere((user) => user['email'] == email);
        print('logged in user ${loggedInUser.toString()}');
        await prefsWithCache.setString(
          'currentUserId',
          loggedInUser['id'].toString(),
        );
        await prefsWithCache.setString(
          'email',
          loggedInUser['email'].toString(),
        );
        await prefsWithCache.setString(
          'userImage',
          loggedInUser['userImage'].toString(),
        );
        print('current user id: ${prefsWithCache.getString('currentUserId')}');
        print('current user email: ${prefsWithCache.getString('email')}');
        print(
          'current user userImage: ${prefsWithCache.getString('userImage')}',
        );
        print('login successful');
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('login successful!')));
          Navigator.pushNamed(context, '/HomeScreen');
        }
      } else {
        print('login failed');
        if (context.mounted) {
          if (user.firstWhere((user) => user['email'] == email)['email'] !=
              email) {
            print(
              'no such user ${user.firstWhere((user) => user['email'] == email)['email'] != email}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('login failed user not found')),
            );
          }
          if (user.firstWhere((user) => user['email'] == email)['password'] !=
              password) {
            print(
              'wrong password ${user.firstWhere((user) => user['email'] == email)['password'] != password}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('login failed check password')),
            );
          }
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
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
              child: Image.asset('assets/pureshopping logo.png'),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
              child: Card(
                color: Colors.white70,
                child: Padding(
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
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                login(email.text, password.text, context);
                              }
                            },
                            child: Text("login"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/SignupScreen');
                            },
                            child: Text('signup'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/ForgotPasswordScreen',
                            );
                          },
                          child: Text('forgot password?'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
