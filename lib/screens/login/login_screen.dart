import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/repositories/auth_repository.dart';
import 'package:preparate_icfes_seminario/screens/login/bloc/authentication_bloc.dart';
import 'package:preparate_icfes_seminario/screens/login/bloc/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        authRepository: context.read<AuthRepository>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.submissionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Error de autenticación'),
                ),
              );
          } else if (state.status == LoginStatus.submissionSuccess) {
            // Cuando el login es exitoso, actualizar el AuthenticationBloc
            // El router automáticamente redirigirá según el estado de autenticación
            context.read<AuthenticationBloc>().add(
                  AuthenticationSubscriptionRequested(),
                );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header verde con ícono
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    // Ícono de graduación
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              // Formulario
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Campo de correo electrónico
                    const Text(
                      'Correo electrónico',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _EmailInput(),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PasswordInput(),
                    const SizedBox(height: 12),
                    // Olvidaste tu contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navegar a recuperar contraseña
                        },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botón de iniciar sesión
                    _LoginButton(),
                    const SizedBox(height: 24),
                    // Registrarse
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes cuenta? ',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar a registro
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (email) =>
              context.read<LoginBloc>().add(LoginEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'tucorreo@ejemplo.com',
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.grey[600],
            ),
            filled: true,
            fillColor: AppColors.secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.obscurePassword != current.obscurePassword,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<LoginBloc>().add(LoginPasswordChanged(password)),
          obscureText: state.obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.grey[600],
            ),
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
              ),
              onPressed: () {
                context
                    .read<LoginBloc>()
                    .add(const LoginPasswordVisibilityChanged());
              },
            ),
            filled: true,
            fillColor: AppColors.secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            key: const Key('loginForm_continue_raisedButton'),
            onPressed: state.status == LoginStatus.submissionInProgress
                ? null
                : () {
                    context.read<LoginBloc>().add(const LoginSubmitted());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: state.status == LoginStatus.submissionInProgress
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
