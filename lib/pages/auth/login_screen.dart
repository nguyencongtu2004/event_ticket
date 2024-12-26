import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/requests/auth_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/service/auth_service.dart';
import 'package:event_ticket/service/firebase_service.dart';
import 'package:event_ticket/utils/provider_utils.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.email = '',
    this.password = '',
  });

  final String? email;
  final String? password;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final _authRequest = AuthRequest();
  var _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
  }

  void handleLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      setState(() => _isLoading = true);
      final response = await _authRequest.login(
        email: email,
        password: password,
      );
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final role = Roles.values.firstWhere(
            (r) => r.value == (response.data['user']['role'] as String));

        FirebaseService.syncFCMToken();
        await AuthService.setAuthBearerToken(token);
        await AuthService.setRole(role);

        invalidateAllProvidersExceptCategory(ref);

        switch (role) {
          case Roles.eventCreator:
            context.go(Routes.eventManagement);
            break;
          case Roles.ticketBuyer:
            context.go(Routes.event);
            break;
          case Roles.admin:
            context.go(Routes.admin);
            break;
        }
      } else {
        if (mounted) {
          context.showAnimatedToast(response.data['message'], isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showAnimatedToast('Login failed: $e', isError: true);
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo hoặc tiêu đề
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Email Input
              TextField(
                // controller: emailController..text = 'congtu2132004@gmail.com',
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

              // Password Input
              TextField(
                // controller: passwordController..text = '12345678',
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

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push(Routes.forgotPassword);
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 16),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary)
                        .wh(24, 24)
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      context.go(Routes.register, extra: {
                        'email': emailController.text,
                        'password': passwordController.text,
                      });
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
