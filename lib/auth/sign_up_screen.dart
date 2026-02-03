import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  Future<void> _signup() async {
    if (name.text.isEmpty ||
        phone.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService().signUp(
        name: name.text,
        phone: phone.text,
        email: email.text,
        password: password.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // return to feed
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")),
              TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : _signup,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("SIGN UP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
