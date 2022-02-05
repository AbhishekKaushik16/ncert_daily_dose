import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notes_app/screens/components/home_screens.dart';
import 'package:notes_app/screens/loading_screen.dart';

import '../signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset('assets/splash_bg.svg', fit: BoxFit.fill),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF6CD8D1),
                      ),
                      child: const Text("Admin? Sign Up"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoadingScreen(isAdmin: false)));
                    },
                    child: const SizedBox(
                      child: Center(child: Text("Don't have a account? Explore App.")),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}
