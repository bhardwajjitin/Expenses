import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() {
    return _Signup();
  }
}

class _Signup extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cpassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();

  void createAcc() async {
    String email = emailController.text.trim();
    String pass = password.text.trim();
    String cpass = cpassword.text.trim();
    String nam = name.text.trim();
    String dat = date.text.trim();
    if (email == "" || pass == "" || cpass == "" || nam == "" || dat == "") {
      _showSnackBar("Please Fill All the Details");
    } else if (pass != cpass) {
      _showSnackBar("Passwords don't match");
    } else if (pass.length < 8) {
      _showSnackBar("Password is too short");
    } else {
      // create new account
      try {
        // for creating users
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);

        // for storing the users data
        String userid = userCredential.user!.uid;
        await FirebaseFirestore.instance
            .collection('Users Details')
            .doc(userid)
            .set({
          'name': nam,
          'Dob': dat,
          'email': email,
        });

        await userCredential.user!.sendEmailVerification();

        _showSnackBar("Verification email sent! Please check your inbox.");

        await FirebaseAuth.instance.signOut();

        if (mounted) {
          Navigator.pop(context);
        }

        _showSnackBar("User Created Successfully");
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'auth/invalid-email':
            _showSnackBar('The email address is not valid.');
            break;
          case 'auth/user-disabled':
            _showSnackBar('This user account has been disabled.');
            break;
          case 'auth/email-already-in-use':
            _showSnackBar('This email address is already in use.');
            break;
          case 'auth/weak-password':
            _showSnackBar('The password is too weak.');
            break;
          case 'auth/operation-not-allowed':
            _showSnackBar('This operation is not allowed.');
            break;
          default:
            _showSnackBar('${e.message}');
        }
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyBoardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 150, 12, keyBoardSpace + 1),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 5),
                child: TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50.00))),
                    hintText: 'Enter the Name',
                  ),
                  keyboardType: TextInputType.name,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 5),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(50.00))),
                      hintText: 'Enter the Email Address Name'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 5),
                child: TextFormField(
                  controller: password,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(50.00))),
                      hintText: 'Enter the Password'),
                  autocorrect: false,
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 5),
                child: TextFormField(
                  controller: cpassword,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(50.00))),
                      hintText: 'Enter the Confirm Password'),
                  autocorrect: false,
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 5),
                child: TextFormField(
                  controller: date,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () async {
                        DateTime? pickeddate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1960, 1, 1),
                            lastDate: DateTime.now());
                        if (pickeddate != null) {
                          date.text =
                              DateFormat.yMd().format(pickeddate).toString();
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50.00))),
                    hintText: 'Enter your DOB',
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      createAcc();
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
                    child: const Text('Create Account'),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: const ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.00),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
