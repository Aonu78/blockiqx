import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../staff/staff_dashboard_screen.dart';
import 'login_screen.dart'
    show
        _LoginBgPainter,
        _GlassCard,
        _AnimatedField,
        _GradientButton,
        _ErrorBanner;

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen>
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
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade =
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeIn);
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
    final ok = await auth.loginStaff(
        _emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const StaffDashboardScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
    }
  }

  static const _accent = Color(0xFF43A047);
  static const _accentLight = Color(0xFF66BB6A);

  @override
  Widget build(BuildContext context) {
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
                Color.lerp(const Color(0xFF060D17), const Color(0xFF071208),
                    _bgCtrl.value)!,
                Color.lerp(const Color(0xFF071208), const Color(0xFF0D1B2A),
                    _bgCtrl.value)!,
                Color.lerp(const Color(0xFF1B5E20).withOpacity(0.25),
                    const Color(0xFF2E7D32).withOpacity(0.1),
                    _bgCtrl.value)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                    painter:
                        _LoginBgPainter(_bgCtrl.value, _accent)),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: SlideTransition(
                          position: _cardSlide,
                          child: FadeTransition(
                            opacity: _cardFade,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: _accent.withOpacity(0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.badge_outlined,
                                          color: _accentLight, size: 16),
                                      SizedBox(width: 6),
                                      Text('Staff / Outreach',
                                          style: TextStyle(
                                              color: _accentLight,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ShaderMask(
                                  shaderCallback: (b) =>
                                      const LinearGradient(colors: [
                                    _accentLight,
                                    Colors.white
                                  ]).createShader(b),
                                  child: const Text(
                                    'Staff Portal',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sign in to manage your assigned reports',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.45),
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 32),
                                _GlassCard(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _AnimatedField(
                                          controller: _emailCtrl,
                                          label: 'Staff Email',
                                          icon: Icons.email_outlined,
                                          accentColor: _accentLight,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (v) =>
                                              (v == null || !v.contains('@'))
                                                  ? 'Enter a valid email'
                                                  : null,
                                        ),
                                        const SizedBox(height: 16),
                                        _AnimatedField(
                                          controller: _passwordCtrl,
                                          label: 'Password',
                                          icon: Icons.lock_outline,
                                          accentColor: _accentLight,
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
                                          _ErrorBanner(
                                              message: auth.error!),
                                        ],
                                        const SizedBox(height: 24),
                                        _GradientButton(
                                          label: 'Sign In as Staff',
                                          isLoading: auth.isLoading,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF1B5E20),
                                              _accent,
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

