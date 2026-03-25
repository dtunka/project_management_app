import 'package:flutter/material.dart';
import 'package:project_management_app/features/authorization/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _register() async {
  if (_formKey.currentState!.validate()) {

    String fullname = _fullnameController.text.trim();
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {

      await authProvider.register(
        email,
        password,
        "member", // default role (admin can change later)
      );

      if (authProvider.isRegistered) {

        final snackbarDelay = ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Successful! Now you can login"),
          ),
        );

        await snackbarDelay.closed;

        Navigator.pushNamed(context, '/login');

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Registration Failed"),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(
                  " Project Management App",
                  style: const TextStyle(
                    fontSize: 26,
                    color: Color.fromARGB(255, 155, 197, 241), // #0f5841
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Create new account to use the PM app',
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register to Account',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'name',
                        style: TextStyle(fontSize: 16, color: Colors.white60),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _fullnameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                           prefixIconColor: Color(0xFF194F87),
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: "Enter your fullname",
                          hintStyle: TextStyle(color: Colors.white60),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Your name is required";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5),
                      Text(
                        'email',
                        style: TextStyle(fontSize: 16, color: Colors.white60),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          prefixIconColor: Color(0xFF194F87),
                          hintText: 'Enter your email',
                          filled: true,
                          fillColor:  Colors.white10,
                          //Color(0xFF194F87),
                          hintStyle: TextStyle(color: Colors.white60),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          }

                          // Email regex pattern
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (!emailRegex.hasMatch(value.trim())) {
                            return "Enter a valid email address";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 5),
                      Text(
                        'password',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: const Color.fromARGB(255, 166, 159, 207)),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                           prefixIconColor: Color(0xFF194F87),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white30,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isPasswordVisible) {
                                  _isPasswordVisible = false;
                                } else {
                                  _isPasswordVisible = true;
                                }
                              });
                            },
                          ),
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(
                            color: Colors.white30,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Password is required";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        'password confirmation',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        // difference of TextField and TextFieldForm is TextForm doesn't  suppport validation method especially Validator
                        controller: _confirmPasswordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                           prefixIconColor: Color(0xFF194F87),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white30,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isPasswordVisible) {
                                  _isPasswordVisible = false;
                                } else {
                                  _isPasswordVisible = true;
                                }
                              });
                            },
                          ),
                          hintText: 'Confirm your password',
                          hintStyle: TextStyle(
                            color: Colors.white30,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Re-enter your password";
                          }
                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            return "passwords don't match";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF194F87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _register,
                          // () {
                          //   if (_formKey.currentState!.validate()) {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => LoginPage(),
                          //       ),
                          //     );
                          //   }
                          // },
                          child: Text(
                            "Register to PM App",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                             
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
