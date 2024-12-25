import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/requests/auth_request.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterFormBottomSheet extends StatefulWidget {
  final Function onSuccess;

  const RegisterFormBottomSheet({
    super.key,
    required this.onSuccess,
  });

  @override
  State<RegisterFormBottomSheet> createState() =>
      _RegisterFormBottomSheetState();
}

class _RegisterFormBottomSheetState extends State<RegisterFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _authRequest = AuthRequest();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  Roles selectedRole = Roles.ticketBuyer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await _authRequest.register(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _passwordController.text,
      name: _nameController.text,
      role: selectedRole.value,
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
        Navigator.pop(context);
        widget.onSuccess();
      }
    } else {
      context.showAnimatedToast(response.data['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Register New User',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Roles>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: Roles.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _handleSubmit,
              icon: isLoading
                  ? const CircularProgressIndicator().w(20).h(20)
                  : const Icon(Icons.person_add),
              label: const Text('Register User'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
