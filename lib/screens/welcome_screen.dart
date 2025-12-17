import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pin_auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF122E2A),
      body: SafeArea(
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
                      'Zero Deudas',
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
                  child: Image.asset('assets/images/image.webp', height: 250, fit: BoxFit.cover),
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
                      'Domina la regla 50/30/20, elimina tus deudas y aprende a invertir con educación financiera simplificada.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withAlpha(178),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 74),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PinAuthScreen(isSettingPin: true)),
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
      ),
    );
  }
}
