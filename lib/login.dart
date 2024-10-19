import 'package:PennyTrack/widget/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() {
    return _Login();
  }
}

class _Login extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController loginpassword = TextEditingController();
  bool _passwordVisible = false;
  bool _isPasswordFilled = false; // Track if the password field has text

  @override
  void initState() {
    super.initState();
    // Add a listener to the password controller
    loginpassword.addListener(() {
      setState(() {
        _isPasswordFilled =
            loginpassword.text.isNotEmpty; // Check if the field has text
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose(); // Clean up the email controller
    loginpassword.dispose(); // Clean up the password controller
    super.dispose();
  }

  void signIn() async {
    try {
      final login = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: loginpassword.text.trim());
      if (!login.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        _showSnackBar("Please verify your email before logging in.");
        return;
      }
      if (login.user != null) {
        String userid = login.user!.uid;
        var documentSnapshot = await FirebaseFirestore.instance
            .collection('Users Details')
            .doc(userid)
            .get();
        if (documentSnapshot.exists &&
            documentSnapshot.data()?['name'] != null) {
          String name = documentSnapshot.data()!['name'];

          if (mounted) {
            _showSnackBar('Welcome $name');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Expenses(userid: userid)),
            );
          }
        }
      } else {
        _showSnackBar('Please enter user name and password');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'auth/invalid-email':
          _showSnackBar('The email address is not valid.');
          break;
        case 'auth/user-disabled':
          _showSnackBar('This user account has been disabled.');
          break;
        case 'auth/user-not-found':
          _showSnackBar('No user found with this email address.');
          break;
        case 'auth/wrong-password':
          _showSnackBar('The password is incorrect.');
          break;
        case 'auth/operation-not-allowed':
          _showSnackBar('This operation is not allowed.');
          break;
        default:
          _showSnackBar('${e.message}');
      }
    }
  }

  void _showSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(errorMessage), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
                  child: TextFormField(
                    controller: emailController,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(50.00))),
                      hintText: 'Enter the Email Address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 5),
                  child: TextFormField(
                    controller: loginpassword,
                    autocorrect: false,
                    obscureText: _passwordVisible,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(50.00))),
                      hintText: 'Enter the Password here',
                      suffixIcon: _isPasswordFilled
                          ? IconButton(
                              icon: Icon(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white // White icon in dark mode
                                    : Colors.black,
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const SignUp()),
                        );
                      },
                      style: const ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.00))))),
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signIn();
                      },
                      style: const ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.00),
                            ),
                          ),
                        ),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
