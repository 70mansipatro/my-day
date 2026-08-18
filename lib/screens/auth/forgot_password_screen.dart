import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
      _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful. Please login.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Something went wrong. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset your password',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email and choose a new password',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.gray600),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _newPasswordFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  obscureText: _obscureNewPassword,
                  validator: Validators.validatePassword,
                  focusNode: _newPasswordFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureNewPassword = !_obscureNewPassword),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.validateConfirmPassword(
                      value, _newPasswordController.text),
                  focusNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => isLoading ? null : _handleResetPassword(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Reset Password',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
