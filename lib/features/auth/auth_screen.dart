import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('boutique_id')
            .eq('id', response.user!.id)
            .single();

        final boutiqueId = profileData['boutique_id'];
        if (boutiqueId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('boutique_id', boutiqueId);
          if (mounted) context.go('/');
        } else {
          setState(() => _errorMessage = "Aucune boutique associée à ce compte.");
        }
      }
    } on AuthException {
      setState(() => _errorMessage = "Email ou mot de passe incorrect.");
    } catch (_) {
      setState(() => _errorMessage = "Erreur réseau. Vérifiez votre connexion internet.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── LEFT: Hero Panel ──
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFF111111),
              child: Stack(
                children: [
                  // Yellow gradient blob
                  Positioned(
                    top: -80, left: -80,
                    child: Container(
                      width: 400, height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFFFACC15).withOpacity(0.3),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60, right: -60,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFFFACC15).withOpacity(0.15),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo / Brand
                        Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFACC15), Color(0xFFF59E0B)],
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Text('Y', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Yellow Pos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Gérez votre\nboutique avec\nélégance.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: -2.0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Caisse hors-ligne · Sync Cloud · Stock intelligent\nConçu pour les entrepreneurs africains.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Feature pills
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: ['Hors-ligne d\'abord', 'Multi-devise', 'Sync automatique', 'Analytiques Pro']
                              .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                                ),
                                child: Text(tag, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                              )).toList(),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── RIGHT: Login Form ──
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFFF8F8FA),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Bon retour 👋',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF111111), letterSpacing: -1),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Connectez-vous pour accéder à votre caisse',
                            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 32),

                          // Error box
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Email
                          _label('Adresse e-mail'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
                            decoration: _inputDecoration('admin@boutique.com', Icons.email_outlined),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                          ),

                          const SizedBox(height: 18),

                          // Password
                          _label('Mot de passe'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
                            decoration: _inputDecoration('••••••••', Icons.lock_outline_rounded).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 18, color: const Color(0xFF9CA3AF),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                          ),

                          const SizedBox(height: 28),

                          // Submit button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111111),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                disabledBackgroundColor: const Color(0xFF9CA3AF),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Se connecter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Center(
                            child: Text(
                              "Pas encore de compte ? Créez votre boutique sur\nyellowpos.web.app",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), height: 1.6),
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
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
  );

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFACC15), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}
