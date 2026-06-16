import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart' as app_theme;
import '../../core/validators/email_str_validator.dart';
import '../../core/validators/empty_str_validator.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/functions/ui_functions.dart';
import '../../presentation/widgets/input_text_field.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  late final AuthViewModel _viewModel;
  late final void Function() _disposeEffect;
  bool _processingResult = false;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<AuthViewModel>();

    _disposeEffect = effect(() {
      if (_viewModel.signupCommand.isExecuting.value) return;

      final result = _viewModel.signupCommand.result.value;
      if (result == null || _processingResult) return;

      _processingResult = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await result.fold(
          onSuccess: (account) async {
            final saveResult = await _viewModel.saveAccountLocally(account);
            if (!mounted) return;

            if (saveResult.isSuccess) {
              context.goNamed(AppRouteNames.about);
            } else {
              showSnackBar(
                context,
                saveResult.failureValueOrNull?.msg ?? 'Erro ao salvar conta localmente.',
                backgroundColor: Theme.of(context).colorScheme.error,
              );
            }
          },
          onFailure: (failure) {
            if (!mounted) return;
            showSnackBar(
              context,
              failure.msg,
              backgroundColor: Theme.of(context).colorScheme.error,
            );
          },
        );

        _viewModel.signupCommand.clear();
        _processingResult = false;
      });
    });
  }

  @override
  void dispose() {
    _disposeEffect();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      FocusScope.of(context).unfocus();
    }
    return isValid;
  }

  Future<void> _submitSignup() async {
    if (!_validateForm()) return;

    await _viewModel.signupCommand.executeWith(
      (
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.LightModeColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: app_theme.AppSpacing.paddingLg,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(app_theme.AppRadius.xl),
                ),
                elevation: 10,
                child: Padding(
                  padding: app_theme.AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Crie sua conta',
                        style: context.textStyles.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: app_theme.AppSpacing.sm),
                      Text(
                        'Cadastre-se para entrar no jogo e salvar seu progresso.',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: app_theme.AppSpacing.xl),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputTextField(
                              label: 'Nome de usuário',
                              controller: _displayNameController,
                              validator: (value) => validateField(
                                value,
                                [EmptyStrValidator()],
                              ),
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: app_theme.AppSpacing.md),
                            InputTextField(
                              label: 'E-mail',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => validateField(
                                value,
                                [EmailStrValidator()],
                              ),
                              prefixIcon: Icons.mail_outline,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: app_theme.AppSpacing.md),
                            InputTextField(
                              label: 'Senha',
                              controller: _passwordController,
                              obscureText: true,
                              validator: (value) => validateField(
                                value,
                                [EmptyStrValidator()],
                              ),
                              prefixIcon: Icons.lock_outline,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submitSignup(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: app_theme.AppSpacing.lg),
                      Watch((_) {
                        final isBusy = _viewModel.signupCommand.isExecuting.value;
                        return FilledButton(
                          onPressed: isBusy ? null : _submitSignup,
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(
                              vertical: app_theme.AppSpacing.md,
                            ),
                          ),
                          child: isBusy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Cadastrar'),
                        );
                      }),
                      const SizedBox(height: app_theme.AppSpacing.sm),
                      TextButton(
                        onPressed: () => context.goNamed(AppRouteNames.login),
                        child: Text(
                          'Já tem conta? Faça login',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
