import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:notes_app/constants.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/provider/provider_file.dart';
import 'package:notes_app/screens/components/home_screens.dart';
import 'package:notes_app/screens/loading_screen.dart';

class SignupScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Log In",
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("EMAIL"),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(hintText: "test@gmail.com", focusColor: Colors.black, ),
                      validator: EmailValidator(errorText: "Use a valid email!"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("PASSWORD"),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: "*****"),
                      validator: RequiredValidator(errorText: "Enter your password"),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async{
                          if(_formKey.currentState!.validate()) {
                            try {
                              UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text);
                              context.read<ProviderState>().setUserCredential(userCredential);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoadingScreen(isAdmin: true)));
                            } on FirebaseAuthException catch (e) {
                              if(e.code == 'user-not-found') {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text("You are not admin."),
                                ));
                              } else if (e.code == 'wrong-password') {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text("Wrong Password."),
                                ));
                              }
                            }
                          }
                        },
                        child: const Text("Log In"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
