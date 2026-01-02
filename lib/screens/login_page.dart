import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  final TapGestureRecognizer _forgotTap = TapGestureRecognizer();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotTap.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Redirection vers la page d'accueil
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun compte trouvé avec cet email.';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect.';
          break;
        case 'invalid-email':
          message = 'L\'adresse email n\'est pas valide.';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé.';
          break;
        default:
          message = 'Erreur: ${e.message}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFE63946);
    const Color inputBg = Color(0xFFF1F3F5);
    const Color labelGrey = Color(0xFF6C757D);

    final OutlineInputBorder pillBorder = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(24),
    );

    InputDecoration pillDecoration({String? hint}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: pillBorder,
      focusedBorder: pillBorder,
    );

    Text label(String text) => Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.5,
        color: labelGrey,
      ),
    );

    Widget backButton() {
      if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  backButton(),
                  const SizedBox(height: 40),
                  const Text(
                    'Login',
                    style: TextStyle(
                      color: red,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email
                  label('Your Email :'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: pillDecoration(hint: 'david@newas.com'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final ok = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(v);
                      return ok ? null : 'Invalid email';
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  label('Password :'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: pillDecoration(hint: '••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      return v.length >= 6 ? null : 'Min 6 chars';
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Forgot password text (clickable)
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        children: [
                          const TextSpan(text: "Can't login? "),
                          TextSpan(
                            text: 'Forgot Password!',
                            style: const TextStyle(
                              color: red,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _forgotTap
                              ..onTap = () =>
                                  Navigator.of(context).pushNamed('/forgot'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                  // Don't have account
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/register'),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
