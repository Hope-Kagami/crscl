import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/custom_button.dart';
import '../registration/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOTPSent = false;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _useOTP = false;
  String? _message;

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text.trim(),
      );
      setState(() {
        _isOTPSent = true;
        _message = 'OTP sent! Check your email.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: _emailController.text.trim(),
        token: _otpController.text.trim(),
      );
      if (response.user != null) {
        setState(() {
          _message = 'Login successful!';
        });
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _message = 'Invalid OTP or login failed.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithPassword() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (response.user != null) {
        setState(() {
          _message = 'Login successful!';
        });
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _message = 'Invalid credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSocialButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: Colors.black)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Or', style: TextStyle(color: Colors.grey[600])),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo placeholder
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.car_repair,
                    size: 36,
                    color: Color(0xFF202411),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CRSCL',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 36,
                    color: theme.colorScheme.secondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find trusted car repair centers near you',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            _buildSocialButton(
                              'Facebook',
                              Icons.facebook,
                              const Color(0xFF1877F3),
                              () {},
                            ),
                            const SizedBox(width: 12),
                            _buildSocialButton(
                              'Google',
                              Icons.g_mobiledata,
                              const Color(0xFFEA4335),
                              () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        InputField(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          fillColor: theme.colorScheme.surface,
                        ),
                        const SizedBox(height: 16),
                        if (!_useOTP)
                          Column(
                            children: [
                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                style: const TextStyle(fontFamily: 'Manrope'),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_useOTP)
                          Column(
                            children: [
                              if (!_isOTPSent)
                                CustomButton(
                                  label: 'Send OTP',
                                  onPressed: _sendOTP,
                                  isLoading: _isLoading,
                                ),
                              if (_isOTPSent) ...[
                                InputField(
                                  controller: _otpController,
                                  label: 'Enter OTP',
                                  keyboardType: TextInputType.number,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  label: 'Verify OTP',
                                  onPressed: _verifyOTP,
                                  isLoading: _isLoading,
                                ),
                              ],
                            ],
                          ),
                        const SizedBox(height: 16),
                        if (_message != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _message!.startsWith('Error')
                                    ? Icons.error_outline
                                    : Icons.check_circle_outline,
                                color:
                                    _message!.startsWith('Error')
                                        ? Colors.red
                                        : theme.colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _message!,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    color:
                                        _message!.startsWith('Error')
                                            ? Colors.red
                                            : theme.colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        if (!_useOTP)
                          CustomButton(
                            label: 'Log In',
                            onPressed: _loginWithPassword,
                            isLoading: _isLoading,
                          ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _useOTP = !_useOTP;
                                _isOTPSent = false;
                                _otpController.clear();
                                _message = null;
                              });
                            },
                            child: Text(
                              _useOTP
                                  ? 'Back to Password Login'
                                  : 'Or, Log in with OTP',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(fontFamily: 'Manrope'),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const RegistrationScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
