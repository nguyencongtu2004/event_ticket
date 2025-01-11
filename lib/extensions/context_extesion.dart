import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ));
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ));
  }

  void showAnimatedToast(String message, {bool isError = false}) {
    final overlay = Overlay.of(this);
    final width = MediaQuery.sizeOf(this).width;
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        width: width < 600 ? width - 20 : 600,
        left: 10,
        child: AnimatedSnackBar(
          message: message,
          isError: isError,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 6), () {
      overlayEntry.remove();
    });
  }
}

class AnimatedSnackBar extends StatefulWidget {
  final String message;
  final bool isError;

  const AnimatedSnackBar({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Tự động mờ dần và biến mất sau 6 giây
    Future.delayed(const Duration(seconds: 5), () {
      _controller.reverse().then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.isError ? Colors.red : Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
