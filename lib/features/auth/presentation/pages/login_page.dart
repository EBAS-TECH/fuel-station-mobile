import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:station_manager/features/dashboard/pages/home_page.dart';
import 'package:station_manager/l10n/app_localizations.dart';
import 'package:station_manager/shared/lanuage_switcher.dart';
import 'package:station_manager/shared/show_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isChecked = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    final isMediumScreen = size.height >= 600 && size.height < 800;

    final horizontalPadding = size.width < 400 ? 16.0 : 24.0;
    final titleFontSize = size.width < 400 ? 24.0 : 28.0;
    final subtitleFontSize = size.width < 400 ? 14.0 : 16.0;
    final textFieldSpacing = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 16.0
        : 20.0;
    final sectionSpacing = isSmallScreen
        ? 16.0
        : isMediumScreen
        ? 24.0
        : 32.0;
    final buttonVerticalPadding = isSmallScreen ? 14.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [LanguageSwitcher()],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLogInSucess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    HomePage(userId: state.responseData!["id"]),
              ),
            );
          } else if (state is AuthFailure) {
            ShowSnackbar.show(context, state.error, isError: true);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Image.asset(
                isDarkMode
                    ? "assets/images/logo_dark.png"
                    : "assets/images/logo.png",
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              Text(
                l10n.stationLogin,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: textFieldSpacing / 2),
              Text(
                l10n.loginSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: subtitleFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: textFieldSpacing),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: textFieldSpacing),
                    _buildTextField(
                      context,
                      controller: _userNameController,
                      label: l10n.usernameLabel,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.usernameError;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: textFieldSpacing),
                    _buildTextField(
                      context,
                      controller: _passwordController,
                      label: l10n.passwordLabel,
                      obscureText: _obscurePassword,
                      isPasswordField: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.passwordErrorEmpty;
                        }
                        if (value.length < 6) {
                          return l10n.passwordErrorLength;
                        }
                        return null;
                      },
                      onToggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    SizedBox(height: sectionSpacing),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    
                      ],
                    ),
                    SizedBox(height: sectionSpacing),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _submitForm();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: buttonVerticalPadding,
                              ),
                            ),
                            child: state is AuthLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.loginButton,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                    ),
                                  ),
                          );
                        },
                      ),
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool isPasswordField = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onToggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: isPasswordField
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        errorStyle: TextStyle(height: 0),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userName = _userNameController.text.trim();
      final password = _passwordController.text.trim();

      context.read<AuthBloc>().add(
        AuthLoginEvent(userName: userName, password: password),
      );
    }
  }
}

