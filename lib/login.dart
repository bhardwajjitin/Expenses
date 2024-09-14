import 'package:authentication/widget/expenses.dart';
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
  void signIn() async {
    try {
      final login = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: loginpassword.text.trim());
      if (login.user != null) {
        String userid = login.user!.uid;
        if (mounted) {
          _showSnackBar('Signed In Successfully');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Expenses(userid: userid)),
          );
        }
      } else {
        _showSnackBar('please enter user name and password');
      }
    } on FirebaseAuthException catch (e) {
      // Handling specific Firebase Authentication errors

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
    return SingleChildScrollView(
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
                      borderRadius: BorderRadius.all(Radius.circular(50.00))),
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
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50.00))),
                  hintText: 'Enter the Password here',
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
                      CupertinoPageRoute(builder: (context) => const SignUp()),
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
    );
  }
}
