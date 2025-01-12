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
  bool isOrganizer = false;
  final TextEditingController nameController = TextEditingController();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController =
      TextEditingController();
  final _authRequest = AuthRequest();
  var _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
  }

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
        if (mounted) {
          context.go(Routes.login, extra: {
            'email': emailController.text,
            'password': passwordController.text,
          });
        }
      } else {
        if (mounted) {
          context.showAnimatedToast(response.data['message'], isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showAnimatedToast('Register failed: $e', isError: true);
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;

          return Row(
            children: [
              if (isLargeScreen)
                Expanded(
                  child: Container(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/app_icon.png',
                          width: 120,
                          height: 120,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Register',
                          style: context.textTheme.headlineLarge?.copyWith(
                            color: context.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create an account to continue',
                          style: context.textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tiêu đề
                          Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sign up to get started',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Tên
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Mật khẩu
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                          const SizedBox(height: 16),

                          // Xác nhận mật khẩu
                          TextField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                          ),
                          const SizedBox(height: 16),

                          // Chuyển đổi vai trò
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Register as Event Organizer'),
                              Switch(
                                value: isOrganizer,
                                onChanged: (value) =>
                                    setState(() => isOrganizer = value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nút đăng ký
                          ElevatedButton(
                            onPressed: _isLoading ? null : handleRegister,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)
                                    .wh(24, 24)
                                : const Text('Register'),
                          ),
                          const SizedBox(height: 16),

                          // Liên kết đăng nhập
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              TextButton(
                                onPressed: () {
                                  context.go(Routes.login, extra: {
                                    'email': emailController.text,
                                    'password': passwordController.text,
                                  });
                                },
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
