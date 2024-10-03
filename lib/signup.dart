import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        User? user = userCredential.user;

        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': _nameController.text,
            'email': _emailController.text,
            'uid': user.uid,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red.shade200,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.red.shade200,
        child: Column(
          children: [
            // Header Text
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.red.shade200,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Create a new account by filling in your details.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Form with Name, Email, and Password fields
            Expanded(
              flex: 7,
              child: Container(
                decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(-1, -2),
                          blurRadius: 15),
                    ],
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(70))),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),

                        // Name Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.all(25),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.person,
                                  size: 25,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                            ),
                            controller: _nameController,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your name...';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Email Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'User email',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.all(25),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.email_rounded,
                                  size: 25,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                            ),
                            controller: _emailController,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your Email...';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.all(25),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.lock,
                                  size: 25,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              fillColor: Colors.grey.shade200,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                            ),
                            obscureText: true,
                            controller: _passwordController,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your password...';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sign Up Button
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 100),
                              ),
                            ),
                            onPressed: _signUp,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
