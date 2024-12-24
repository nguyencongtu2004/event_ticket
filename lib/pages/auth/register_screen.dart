import 'package:dio/dio.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/requests/auth_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.email = '',
    this.password = '',
  });

  final String? email;
  final String? password;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // State variables
  bool isOrganizer = false;
  final TextEditingController nameController = TextEditingController();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController =
      TextEditingController();
  final _authRequest = AuthRequest();
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
  }

  // Placeholder function
  void handleRegister() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final role =
        isOrganizer ? Roles.eventCreator.value : Roles.ticketBuyer.value;

    Response response;
    try {
      setState(() => _isLoading = true);
      response = await _authRequest.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );
      setState(() => _isLoading = false);
      if (response.statusCode == 201) {
        // Chuyển hướng đến trang chính
        if (mounted) {
          context.go(Routes.login, extra: {
            'email': emailController.text,
            'password': passwordController.text,
          });
        }
      } else {
        // Hiển thị thông báo lỗi
        if (mounted) {
          context.showAnimatedToast(response.data['message'], isError: true);
        }
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
      if (mounted) {
        context.showAnimatedToast('Register failed: $e', isError: true);
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Register',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 20),

          // Email Input
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Input
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          // Confirm Password Input
          TextField(
            controller: confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          // Role Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Switch(
                  value: isOrganizer,
                  onChanged: (value) => setState(() => isOrganizer = value)),
              const SizedBox(width: 8),
              const Text('Register as Event Organizer'),
            ],
          ),
          // Login Button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : handleRegister,
            icon: _isLoading
                ? const CircularProgressIndicator().w(20).h(20)
                : const Icon(Icons.login),
            label: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              context.go(Routes.login, extra: {
                'email': emailController.text,
                'password': passwordController.text,
              });
            },
            child: const Text('Already have an account? Login'),
          ),
        ],
      ).p(16).scrollVertical(),
    );
  }
}
