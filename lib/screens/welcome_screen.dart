import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {}); // Re-render to enable/disable the button
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveNameAndProceed() async {
    if (_nameController.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text.trim());
    _goToPinScreen();
  }

  void _goToPinScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PinAuthScreen(isSettingPin: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF122E2A),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: [_buildWelcomePage(), _buildNameInputPage()],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wallet, color: Color(0xFF30E182), size: 30),
                  const SizedBox(width: 8),
                  Text(
                    '3Way',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  'assets/images/image.webp',
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  Text(
                    'Toma el control',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 36,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'de tu futuro',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 36,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Simplifica tus finanzas con el método 3Way. Domina el 50/30/20, elimina deudas y cultiva tu patrimonio con educación práctica.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withAlpha(178),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Tu fortuna bajo control con el método 3Way.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(178),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30E182),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Empezar Ahora',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF122E2A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameInputPage() {
    final isButtonEnabled = _nameController.text.trim().isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
            ),
            const Spacer(),
            Text(
              '¿Cómo te llamas?',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Saber tu nombre nos ayudará a personalizar tu experiencia.',
              style: GoogleFonts.poppins(
                color: Colors.white.withAlpha(200),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Escribe tu nombre aquí',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(150),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withAlpha(100)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF30E182), width: 2),
                ),
              ),
              onSubmitted: (_) => _saveNameAndProceed(),
            ),
            const Spacer(),
            const Spacer(),
            ElevatedButton(
              onPressed: isButtonEnabled ? _saveNameAndProceed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF30E182),
                disabledBackgroundColor: Colors.grey.shade600,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Continuar',
                style: GoogleFonts.poppins(
                  color: isButtonEnabled
                      ? const Color(0xFF122E2A)
                      : Colors.grey.shade400,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
