import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/requests/auth_request.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _authRequest = AuthRequest();
  bool _isLoading = false;

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      context.showAnimatedToast('Please enter your email', isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);
      final response = await _authRequest.forgetPassword(email);
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        context.showAnimatedToast(
            'Password reset link has been sent to your email');
      } else {
        context.showAnimatedToast(
          response.data['message'] ?? 'Failed to reset password',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      context.showAnimatedToast(
        'An error occurred: $e',
        isError: true,
      );
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 4,
                              color:
                                  context.primaryColor.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/icons/app_icon_removebg.png',
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Forgot Password',
                          style: context.textTheme.headlineLarge?.copyWith(
                            color: context.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter your email to reset your password',
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
                          // Logo hoặc tiêu đề
                          Text(
                            'Forgot Password',
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter your email to reset your password',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Input
                          TextField(
                            controller: _emailController,
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
                          // Reset Password Button
                          ElevatedButton(
                            onPressed:
                                _isLoading ? null : _handleForgotPassword,
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
                                : const Text('Reset Password'),
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
