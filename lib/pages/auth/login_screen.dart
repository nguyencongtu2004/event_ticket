import 'package:event_ticket/enum.dart';
import 'package:event_ticket/requests/auth_request.dart';
import 'package:event_ticket/service/auth_service.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.email = '',
    this.password = '',
  });

  final String? email;
  final String? password;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State variables
  bool isOrganizer = false;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final _authRequest = AuthRequest();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
  }

  // Placeholder function
  void handleLogin() async {
    final email = emailController.text;
    final password = passwordController.text;
    final role =
        isOrganizer ? Roles.eventCreator.value : Roles.ticketBuyer.value;

    try {
      final response = await _authRequest.login(
        email: email,
        password: password,
        role: role,
      );

      if (response.statusCode == 200) {
        // Lưu token vào shared preferences
        AuthService.setAuthBearerToken(response.data['token']);
        print('Token: ${response.data['token']}');

        // Chuyển hướng đến trang chính
        if (mounted) {
          context.pushReplacement('/home');
        }
      } else {
        // Hiển thị thông báo lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Login',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email Input
          TextField(
            controller: emailController..text = 'congtu2132004@gmail.com',
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          // Password Input
          TextField(
            controller: passwordController..text = '12345678',
            decoration: const InputDecoration(
              labelText: 'Password',
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
              const Text('Login as Event Organizer'),
            ],
          ),
          // Login Button
          ElevatedButton(
            onPressed: handleLogin,
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              context.go('/register', extra: {
                'email': emailController.text,
                'password': passwordController.text,
              });
            },
            child: const Text('Register'),
          ),
        ],
      ).p(16),
    );
  }
}
