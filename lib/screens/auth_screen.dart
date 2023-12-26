import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/user_image_picker.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLogin = true;
  var _enteredEmail = '';
  var _enteredUserName = '';
  var _enteredPass = '';
  File? _pickedImage;
  bool _isAuthentication = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid || !_isLogin && _pickedImage == null) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isAuthentication = true;
      });
      if (_isLogin) {
        final userCredintials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPass);
      } else {
        final userCredintials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPass);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child('${userCredintials.user!.uid}.jpg');
        await storageRef.putFile(_pickedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredintials.user!.uid)
            .set({
          'userName': _enteredUserName,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
        setState(() {
          _isAuthentication = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 30, bottom: 20, left: 20, right: 20),
                    width: 200,
                    child: Image.asset('assets/images/chat.png'),
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isLogin)
                                UserImagePicker(
                                  onPickImage: (pickedImage) {
                                    _pickedImage = pickedImage;
                                  },
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Email Address'),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (email) {
                                  if (email == null ||
                                      email.trim().isEmpty ||
                                      !email.contains('@')) {
                                    return 'please enter a valid email address';
                                  }
                                  return null;
                                },
                                onSaved: (email) {
                                  _enteredEmail = email!;
                                },
                              ),

                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'password'),
                                obscureText: true,
                                validator: (pass) {
                                  if (pass == null ||
                                      pass.trim().isEmpty ||
                                      pass.length < 6) {
                                    return 'password must contain Atleast 6 characters';
                                  }
                                  return null;
                                },
                                onSaved: (pass) {
                                  _enteredPass = pass!;
                                },
                              ),
                              if (!_isLogin)
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().length < 5) {
                                      return 'please enter valid username';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _enteredUserName = value!;
                                  },
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (_isAuthentication)
                                const CircularProgressIndicator(),
                              if (!_isAuthentication)
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  child: Text(!_isLogin ? 'Sign Up' : 'Login'),
                                ),
                              if (!_isAuthentication)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create Account'
                                      : 'I Already have an Account'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
