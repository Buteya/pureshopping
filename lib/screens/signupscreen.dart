import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pureshopping/models/user.dart';
import 'package:uuid/uuid.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool isTextObscure = true;
  bool isTextObscure1 = true;
  final ImagePicker picker = ImagePicker();
  XFile? pickedImage;
  final userId = Uuid().v8();
  bool isLoading = false;

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:isLoading? Center(child: CircularProgressIndicator(),): SingleChildScrollView(
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
                pickedImage == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Icon(Icons.image),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Card(
                          child: SizedBox(
                            child: Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pickerImage = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      setState(() {
                        pickedImage = pickerImage;
                      });
                    },
                    label: Text('pick image'),
                    icon: Icon(Icons.image),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: firstname,
                    decoration: InputDecoration(labelText: "firstname"),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a firstname';
                      }
                      if (value.length < 3) {
                        return 'firstname should be more than 3 letters';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: lastname,
                    decoration: InputDecoration(labelText: "lastname"),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a lastname';
                      }
                      if (value.length < 3) {
                        return 'lastname should be more than 3 letters';
                      }
                      return null;
                    },
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
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      formKey.currentState!.validate();
                      if (formKey.currentState!.validate() == true) {
                        final user = User(
                          id: userId,
                          firstname: firstname.text,
                          lastname: lastname.text,
                          email: email.text,
                          password: password.text,
                          userImage: pickedImage!.path,
                        );
                        try {
                          setState(() {
                            isLoading = true;
                          });
                          final users = await user.users();
                          print('all users: ${await user.users()}');
                          print(
                            'user does not exist: ${users.firstWhere((user) => user.email == email.text).email != email.text}',
                          );
                          if (users
                                  .firstWhere(
                                    (user) => user.email == email.text,
                                  )
                                  .email !=
                              email.text) {
                            user.insertUser(user);
                            print('user ${email.text} added successfully');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'user ${email.text} added successfully',
                                  ),
                                ),
                              );
                              Navigator.pushNamed(context, '/LoginScreen');
                            }
                          } else {
                            print('user ${email.text} already exist');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'user ${email.text} already  exists',
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }

                        print('list of all users: ${await user.users()}');
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    label: Text('signup'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 48),
                  child: TextButton(
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
      ),
    );
  }
}
