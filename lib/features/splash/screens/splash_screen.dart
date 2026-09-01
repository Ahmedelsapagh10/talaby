import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static final Uri _portfolioUrl = Uri.parse(
    'https://elsapagh.octopusteam.net/',
  );

  late Timer _timer;

  Future<void> _openPortfolio() async {
    await launchUrl(_portfolioUrl, mode: LaunchMode.externalApplication);
  }

  void _goNext() {
    _getStoreUser();
  }

  Future<void> _startDelay() async {
    _timer = Timer(const Duration(seconds: 8, milliseconds: 500), () {
      _goNext();
    });
  }

  Future<void> _getStoreUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (prefs.getBool('onBoarding') == true) {
      //! un comment this case u make user mode
      //! and store it in locl and want use it
      //!  to check user make login before or not
      //  if (prefs.getString('user') != null) {
      //     Navigator.pushReplacementNamed(context, Routes.mainRoute);
      //   } else {
      context.go(Routes.loginRoute);
      //   }
    } else {
      context.go(Routes.onboardingPageScreenRoute);
    }
  }

  @override
  void initState() {
    super.initState();
    // context.read<SplashCubit>().getAdsOfApp();

    _startDelay();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191B1A),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Hero(
              tag: 'logo',
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: 'MajorMonoDisplay',
                  fontSize: 48.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Talaby',
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                  totalRepeatCount: 1,
                  displayFullTextOnTap: true,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 24,
            left: 0,
            child: SafeArea(
              top: false,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextButton(
                    onPressed: _openPortfolio,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    child: const Text(
                      'تواصل معنا',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
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
    //   },
    // );
  }
}
