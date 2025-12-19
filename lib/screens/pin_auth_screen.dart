import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class PinAuthScreen extends StatefulWidget {
  final bool isSettingPin;

  const PinAuthScreen({super.key, this.isSettingPin = false});

  @override
  PinAuthScreenState createState() => PinAuthScreenState();
}

class PinAuthScreenState extends State<PinAuthScreen> {
  final _pinController = TextEditingController();
  final _nameController = TextEditingController(); // Controller for the name
  String? _tempPin;
  bool _isConfirming = false;
  String _headerText = 'Ingresa tu PIN';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.isSettingPin) {
      _headerText = 'Crea tu PIN de 4 dígitos';
    }
  }

  Future<void> _submitPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.isSettingPin) {
      if (!_isConfirming) {
        // First step: User has entered the PIN for the first time
        setState(() {
          _tempPin = pin;
          _isConfirming = true;
          _headerText = 'Confirma tu PIN';
          _errorMessage = '';
          _pinController.clear();
        });
      } else {
        // Second step: User is confirming the PIN
        if (_tempPin == pin) {
          // PINs match, save PIN and Name
          await prefs.setString('user_pin', pin);
          final name = _nameController.text.trim();
          if (name.isNotEmpty) {
            await prefs.setString('user_name', name);
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // PINs don't match, reset the process
          setState(() {
            _errorMessage = 'Los PINs no coinciden. Inténtalo de nuevo.';
            _headerText = 'Crea tu PIN de 4 dígitos';
            _isConfirming = false;
            _tempPin = null;
            _pinController.clear();
          });
        }
      }
    } else {
      // This is the login flow
      final savedPin = prefs.getString('user_pin');
      if (savedPin == pin) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'PIN incorrecto. Inténtalo de nuevo.';
          _pinController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.onSurface.withAlpha((255 * 0.2).round()),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: theme.colorScheme.primary, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: theme.colorScheme.primaryContainer.withAlpha(
          (255 * 0.5).round(),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isSettingPin
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  if (_isConfirming) {
                    setState(() {
                      _isConfirming = false;
                      _tempPin = null;
                      _headerText = 'Crea tu PIN de 4 dígitos';
                      _errorMessage = '';
                      _pinController.clear();
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _headerText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (widget.isSettingPin && !_isConfirming)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Tu Nombre (Opcional)',
                            hintText: '¿Cómo te llamas?',
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    Pinput(
                      controller: _pinController,
                      length: 4,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      showCursor: true,
                      onCompleted: (pin) => _submitPin(pin),
                      obscureText: true,
                      obscuringCharacter: '●',
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Text(
                'Desarrollado por Edax Perú',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
