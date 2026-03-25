import 'package:flutter/material.dart';
import 'package:project_management_app/features/authorization/presentation/providers/auth_provider.dart';
import 'package:project_management_app/features/authorization/presentation/pages/register.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SingleChildScrollView(
        child: Form(
          key: _formKey,

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                const SizedBox(height: 40),

                const Text(
                  "Project Management",
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'Login to Account',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Email',
                        style: TextStyle(fontSize: 16, color: Colors.white60),
                      ),

                      const SizedBox(height: 5),

                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'Enter your email',
                          filled: true,
                          fillColor: Colors.white10,
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Password',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),

                      const SizedBox(height: 5),

                      TextFormField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.white),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white30,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),

                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: Colors.white30),

                          filled: true,
                          fillColor: Colors.white10,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 178, 198, 236),
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(

                          onPressed: () async {
  if (_formKey.currentState!.validate()) {

    await provider.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    // check role from provider.user
    if (provider.user != null) {
      if (provider.user!.role == "admin") {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }
},

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF194F87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          child: const Text(
                            "Login to PM",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Don't have an account",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(

                          onPressed: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );

                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black12,
                            side: const BorderSide(color: Color(0xFF194F87)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF194F87),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'By logging in, you agree to our Terms and Conditions',
                  style: TextStyle(fontSize: 10, color: Colors.white30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}