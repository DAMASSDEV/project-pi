import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

void showTopToast(BuildContext context, String message, {bool isError = false}) {
  final overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => TopToastWidget(
      message: message,
      isError: isError,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  overlayState.insert(overlayEntry);
}

class TopToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const TopToastWidget({
    super.key,
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<TopToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      _dismiss();
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isError ? Colors.redAccent : AppTheme.primaryColor;
    final bgColor = widget.isError ? const Color(0xFFFFF5F5) : const Color(0xFFF0FAF7);
    final icon = widget.isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: themeColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
