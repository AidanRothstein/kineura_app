import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dashboard_screen.dart';
import 'confirm_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthdateController = TextEditingController();

  String _errorMessage = '';

  Future<void> _signUp() async {
    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();
      final gender = _genderController.text.trim();
      final birthdate = _birthdateController.text.trim(); // YYYY-MM-DD

      final options = CognitoSignUpOptions(
        userAttributes: {
          CognitoUserAttributeKey.email: email,
          CognitoUserAttributeKey.name: name,
          CognitoUserAttributeKey.gender: gender,
          CognitoUserAttributeKey.birthdate: birthdate,
        },
      );

      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: options,
      );

      if (result.isSignUpComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up complete!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Confirmation code sent!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmScreen(username: username),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: _birthdateController,
                decoration: const InputDecoration(labelText: 'Birthdate (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Create Account'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
