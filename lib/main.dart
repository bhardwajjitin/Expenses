import 'package:PennyTrack/widget/expenses.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 186, 63, 217),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromRGBO(186, 63, 217, 1),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // User is signed in, navigate to the home screen
            String userid = snapshot.data!.uid;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              darkTheme: ThemeData.dark().copyWith(
                colorScheme: kDarkColorScheme,
                cardTheme: const CardTheme().copyWith(
                  color: kDarkColorScheme.secondaryContainer,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkColorScheme.primaryContainer,
                    foregroundColor: kDarkColorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              theme: ThemeData().copyWith(
                colorScheme: kColorScheme,
                appBarTheme: const AppBarTheme().copyWith(
                  backgroundColor: kColorScheme.onPrimaryContainer,
                  foregroundColor: kColorScheme.primaryContainer,
                ),
                cardTheme: const CardTheme().copyWith(
                  color: kColorScheme.secondaryContainer,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorScheme.primaryContainer,
                  ),
                ),
                textTheme: ThemeData().textTheme.copyWith(
                      titleLarge: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kColorScheme.onSecondaryContainer,
                      ),
                    ),
              ),
              themeMode: ThemeMode.system,
              home: Expenses(userid: userid),
            );
          } else {
            // User is not signed in, navigate to the login screen
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              darkTheme: ThemeData.dark().copyWith(
                colorScheme: kDarkColorScheme,
                cardTheme: const CardTheme().copyWith(
                  color: kDarkColorScheme.secondaryContainer,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkColorScheme.primaryContainer,
                    foregroundColor: kDarkColorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              theme: ThemeData().copyWith(
                colorScheme: kColorScheme,
                appBarTheme: const AppBarTheme().copyWith(
                  backgroundColor: kColorScheme.onPrimaryContainer,
                  foregroundColor: kColorScheme.primaryContainer,
                ),
                cardTheme: const CardTheme().copyWith(
                  color: kColorScheme.secondaryContainer,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorScheme.primaryContainer,
                  ),
                ),
                textTheme: ThemeData().textTheme.copyWith(
                      titleLarge: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kColorScheme.onSecondaryContainer,
                      ),
                    ),
              ),
              themeMode: ThemeMode.system,
              home: const Scaffold(
                body: Center(
                  child: LoginScreen(),
                ),
              ),
            );
          }
        } else {
          // While checking the auth state, show a loading indicator
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }
}
