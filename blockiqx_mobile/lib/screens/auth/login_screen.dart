import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../community/home_screen.dart';
import '../community/submit_report_screen.dart';
import 'signup_screen.dart';
import 'shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  final bool asGuest;
  const LoginScreen({super.key, this.asGuest = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  late AnimationController _bgCtrl;
  late AnimationController _cardCtrl;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();

    if (widget.asGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => const SubmitReportScreen(isGuest: true)));
      });
    }

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);

    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeIn);

    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _bgCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.loginUser(
        _emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CommunityHomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asGuest) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF060D17), const Color(0xFF0A1628),
                    _bgCtrl.value)!,
                Color.lerp(const Color(0xFF0A1628), const Color(0xFF0D1B2A),
                    _bgCtrl.value)!,
                Color.lerp(const Color.fromRGBO(13, 71, 161, 0.3),
                    const Color.fromRGBO(21, 101, 192, 0.1),
                    _bgCtrl.value)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                    painter: LoginBgPainter(
                        _bgCtrl.value, const Color(0xFF1E88E5))),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SlideTransition(
                          position: _cardSlide,
                          child: FadeTransition(
                            opacity: _cardFade,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                // Role badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(30, 136, 229, 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color.fromRGBO(30, 136, 229, 0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.people_alt_outlined,
                                          color: Color(0xFF42A5F5), size: 16),
                                      SizedBox(width: 6),
                                      Text('Community Member',
                                          style: TextStyle(
                                              color: Color(0xFF42A5F5),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ShaderMask(
                                  shaderCallback: (b) =>
                                      const LinearGradient(colors: [
                                    Color(0xFF42A5F5),
                                    Colors.white
                                  ]).createShader(b),
                                  child: const Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Sign in to report and track incidents',
                                  style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.45),
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 32),
                                // Glass card
                                GlassCard(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        AnimatedField(
                                          controller: _emailCtrl,
                                          label: 'Email Address',
                                          icon: Icons.email_outlined,
                                          accentColor: const Color(0xFF42A5F5),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (v) =>
                                              (v == null || !v.contains('@'))
                                                  ? 'Enter a valid email'
                                                  : null,
                                        ),
                                        const SizedBox(height: 16),
                                        AnimatedField(
                                          controller: _passwordCtrl,
                                          label: 'Password',
                                          icon: Icons.lock_outline,
                                          accentColor: const Color(0xFF42A5F5),
                                          obscure: _obscure,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscure
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color: Colors.white38,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                                () => _obscure = !_obscure),
                                          ),
                                          validator: (v) =>
                                              (v == null || v.length < 6)
                                                  ? 'Minimum 6 characters'
                                                  : null,
                                        ),
                                        if (auth.error != null) ...[
                                          const SizedBox(height: 14),
                                          ErrorBanner(message: auth.error!),
                                        ],
                                        const SizedBox(height: 24),
                                        GradientButton(
                                          label: 'Sign In',
                                          isLoading: auth.isLoading,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF1565C0),
                                              Color(0xFF1E88E5)
                                            ],
                                          ),
                                          onTap: auth.isLoading
                                              ? null
                                              : _submit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: const TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.4),
                                      fontSize: 13,
                                    ),
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const SignupScreen(),
                                            ),
                                          ),
                                          child: const Text(
                                            'Sign up',
                                            style: TextStyle(
                                              color: Color(0xFF42A5F5),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SubmitReportScreen(isGuest: true),
                                    ),
                                  ),
                                  child: const Text(
                                    'Continue as guest',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.55),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
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
}
