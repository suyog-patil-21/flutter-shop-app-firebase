import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/http_exceptions.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  late AnimationController _animatiobnController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animatiobnController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(
            begin: Offset(0, -1.5), end: Offset(0,0))
        .animate(CurvedAnimation(
            parent: _animatiobnController, curve: Curves.fastOutSlowIn));
    // _heightAnimation.addListener(() => setState(() {}));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animatiobnController, curve: Curves.easeIn),
    );
    
  }

  @override
  void dispose() {
    _animatiobnController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('An Error Occured!'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Okay'))
            ],
          );
        });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
            _authData['email'].toString(), _authData['password'].toString());
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'].toString(), _authData['password'].toString());
      }
    } on HttpException catch (error) {
      var errorMessage = "Authenticaton Failed.";
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This Email Address already in Use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not valid Email.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'The password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could Not found user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage =
          "Could Not Authenticate you Please try again later. \n$error";
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animatiobnController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animatiobnController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _authMode == AuthMode.Signup ? 320 : 260,
          // height: _heightAnimation.value.height,
          constraints: BoxConstraints(
              minHeight: _authMode == AuthMode.Signup ? 320 : 260),
          width: deviceSize.width * 0.75,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      }
                    },
                    onSaved: (value) {
                      _authData['email'] = value.toString();
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value.toString();
                    },
                  ),
                  // if (_authMode == AuthMode.Signup)
                  AnimatedContainer(
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position:_slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      child: Text(
                          _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                      onPressed: _submit,
                    ),
                  TextButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
