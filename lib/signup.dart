import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'profile_page.dart';
import 'fire_auth.dart';
import 'dart:math';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _signupFormKey = GlobalKey<FormState>();

  final _usernameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _cityTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  final _focuscity = FocusNode();

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
        _focuscity.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.green,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _signupFormKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 30),
                      SizedBox(
                        width: 400,
                        child: reusableTextField(
                            "Enter Username", Icons.person_outline, false,
                            _usernameTextController, focusNode: _focusName),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 400,
                        child: reusableTextField(
                            "Enter Email Id", Icons.person_outline, false,
                            _emailTextController, focusNode: _focusEmail),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 400,
                        child: reusableTextField(
                            "Enter Password", Icons.lock_outline, true,
                            _passwordTextController, focusNode: _focusPassword),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 400,
                        child: reusableTextField(
                            "Enter City", Icons.person_outline, false,
                            _cityTextController, focusNode: _focuscity),
                      ),
                      SizedBox(height: 32.0),
                      _isProcessing
                          ? CircularProgressIndicator()
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 400,
                            child: SignUpButton(context, true),
                          ),
                        ],
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextField reusableTextField(String text, IconData icon, bool isPasswordType,
      TextEditingController controller,
      {required FocusNode focusNode}) {
    return TextField(
      controller: controller,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.white.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.white,
        ),
        labelText: text,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: isPasswordType
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
    );
  }

  Container SignUpButton(BuildContext context, bool isLogin) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            _isProcessing = true;
            _errorMessage = null; // Clear previous error message
          });

          if (_signupFormKey.currentState!.validate()) {
            User? user = await FireAuth.registerUsingEmailPassword(
              name: _usernameTextController.text,
              email: _emailTextController.text,
              password: _passwordTextController.text,
            );

            setState(() {
              _isProcessing = false;
            });

            if (user != null) {
              await createUserDocument(user);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: user),
                ),
                ModalRoute.withName('/'),
              );
            } else {
              setState(() {
                _errorMessage = 'Sign up failed. Please try again.';
              });
            }
          }
        },
        child: Text(
          "SIGN UP",
          style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createUserDocument(User user) async {
    final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

    // Generate a random rating between 2 and 5
    final Random random = Random();
    int rating = random.nextInt(4) + 2;

    Map<String, dynamic> userData = {
      'id': user.uid,
      'Name': _usernameTextController.text,
      'Animals Owned': 0,
      'City': _cityTextController.text,
      'Rating': rating,
      'Shortlist': [],
      'email': user.email,
      'Myanimals' : [],
    };

    await usersCollection.doc(user.uid).set(userData);
  }
}
