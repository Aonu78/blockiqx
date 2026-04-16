
import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoginBgPainter extends CustomPainter {
  final double t;
  final Color color;
  const LoginBgPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i < 5; i++) {
      paint.color =
          color.withAlpha(10 + i * 2);
      final r = 80.0 + i * 60 + math.sin(t * math.pi + i) * 15;
      canvas.drawCircle(
          Offset(size.width + 20, -20), r, paint);
      canvas.drawCircle(
          Offset(-20, size.height + 20), r * 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(LoginBgPainter old) =>
      old.t != t || old.color != color;
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AnimatedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AnimatedField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<AnimatedField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusCtrl;
  late Animation<double> _borderAnim;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _borderAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_focusCtrl);
  }

  @override
  void dispose() {
    _focusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() => _focused = focused);
        if (focused) {
          _focusCtrl.forward();
        } else {
          _focusCtrl.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _borderAnim,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: widget.accentColor.withAlpha(51),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: child,
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _focused
                  ? widget.accentColor
                  : const Color.fromRGBO(255, 255, 255, 0.4),
              fontSize: 13,
            ),
            prefixIcon: Icon(widget.icon,
                color: _focused
                    ? widget.accentColor
                    : const Color.fromRGBO(255, 255, 255, 0.3),
                size: 20),
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.1), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: widget.accentColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const GradientButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.gradient,
    this.onTap,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.onTap == null
                ? LinearGradient(
                    colors: widget.gradient.colors
                        .map((c) => c.withAlpha(102))
                        .toList())
                : widget.gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.onTap == null
                ? []
                : [
                    BoxShadow(
                      color:
                          widget.gradient.colors.last.withAlpha(102),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
          ),
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 0, 0, 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromRGBO(255, 0, 0, 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
