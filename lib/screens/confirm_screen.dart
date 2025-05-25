import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'home_screen.dart'; // 👈 import your home screen

class ConfirmScreen extends StatefulWidget {
  final String username;
  const ConfirmScreen({super.key, required this.username});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final _codeController = TextEditingController();
  String _errorMessage = '';

  Future<void> _confirm() async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: widget.username,
        confirmationCode: _codeController.text.trim(),
      );

      if (result.isSignUpComplete) {
        // Show success and return to HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Successful confirmation! Please log in.')),
        );

        // Delay to let user read the snackbar before navigating
        await Future.delayed(const Duration(milliseconds: 1500));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // remove all previous routes
        );
      } else {
        setState(() {
          _errorMessage = 'Confirmation incomplete.';
        });
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
      appBar: AppBar(title: const Text("Confirm Your Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Enter the verification code sent to your email."),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Confirmation Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirm,
              child: const Text('Confirm Account'),
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
    );
  }
}
