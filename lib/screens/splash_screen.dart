import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final provider = context.read<VehicleProvider>();
    await provider.load();

    if (mounted) {
      // Wait minimum 2 seconds on splash screen
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashboardScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);
    const yellow = Color(0xFFFFD600);
    const red = Color(0xFFFF0044);

    return Scaffold(
      backgroundColor: yellow,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Static Logo (no animation to reduce work)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: black, width: 4),
                boxShadow: const [
                  BoxShadow(color: black, offset: Offset(6, 6), blurRadius: 0),
                ],
              ),
              child: const Image(
                image: AssetImage('FleetTax.png'),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: black, width: 3),
                boxShadow: const [
                  BoxShadow(color: black, offset: Offset(4, 4), blurRadius: 0),
                ],
              ),
              child: const Text(
                'FLEETTAX',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  letterSpacing: 3,
                  color: black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: red,
                border: Border.all(color: black, width: 2),
              ),
              child: const Text(
                'TAX TRACKER',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Simple loading dots
            _SimpleLoadingDots(),
            const Spacer(),
            // Footer texts
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: black, width: 2),
                    ),
                    child: const Text(
                      'MADE BY DEVANSH SINGH',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 2,
                        color: black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: black, width: 1),
                    ),
                    child: const Text(
                      'A PROPERTY OF SHYAM RATH TOUR & TRAVELS',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1,
                        color: black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SimpleLoadingDots extends StatefulWidget {
  @override
  State<_SimpleLoadingDots> createState() => _SimpleLoadingDotsState();
}

class _SimpleLoadingDotsState extends State<_SimpleLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final opacity = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: black.withValues(alpha: opacity > 0.5 ? 1.0 : 0.3),
                border: Border.all(color: black, width: 2),
              ),
            );
          }),
        );
      },
    );
  }
}