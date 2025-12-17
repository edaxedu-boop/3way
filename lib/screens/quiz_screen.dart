import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;

  final List<Question> _questions = [
    Question(
      text: 'Según la regla 50/30/20, ¿qué porcentaje de tus ingresos netos debe destinarse a "Necesidades"?',
      options: ['30%', '50%', '20%', '40%'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'El 30% de la regla corresponde a tus "Deseos". ¿Cuál de estos es un ejemplo de un deseo?',
      options: ['El alquiler de tu casa', 'Comprar un videojuego nuevo', 'Pagar la factura de la luz', 'La compra del supermercado'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'El 20% final de la regla se destina a "Ahorros e Inversiones". ¿Qué incluye esta categoría?',
      options: ['Cenar en un restaurante caro', 'Pagar deudas pendientes y ahorrar', 'Ir al cine', 'Comprar ropa de marca'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: '¿Cuál es el objetivo principal de la regla 50/30/20?',
      options: ['Gastar todo tu dinero cada mes', 'Nunca darte un gusto', 'Ayudarte a gestionar tu dinero de forma equilibrada', 'Solo ahorrar para la jubilación'],
      correctAnswerIndex: 2,
    ),
    Question(
      text: 'Si tus ingresos netos son de S/ 2,000, ¿cuánto deberías destinar a tus "Necesidades"?',
      options: ['S/ 600', 'S/ 1,000', 'S/ 400', 'S/ 800'],
      correctAnswerIndex: 1,
    ),
  ];

  void _answerQuestion(int selectedIndex) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;
      if (selectedIndex == _questions[_questionIndex].correctAnswerIndex) {
        _score++;
      }
    });

    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; 
      if (_questionIndex < _questions.length - 1) {
        setState(() {
          _questionIndex++;
          _isAnswered = false;
          _selectedAnswerIndex = null;
        });
      } else {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: _score,
              totalQuestions: _questions.length,
              onRestart: () {
                setState(() {
                  _questionIndex = 0;
                  _score = 0;
                  _isAnswered = false;
                  _selectedAnswerIndex = null;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final question = _questions[_questionIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Quiz Financiero', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pregunta ${_questionIndex + 1}/${_questions.length}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF30E182)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1F222A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((255 * 0.05).round()), blurRadius: 10)],
              ),
              child: Text(
                question.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(question.options.length, (index) {
              Color buttonColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;
              Color borderColor = Colors.transparent;
              Color textColor = isDarkMode ? Colors.white : Colors.black87;

              if (_isAnswered) {
                if (index == _selectedAnswerIndex) {
                  borderColor = index == question.correctAnswerIndex ? Colors.greenAccent : Colors.redAccent;
                  buttonColor = index == question.correctAnswerIndex ? Colors.green.withAlpha((255 * 0.1).round()) : Colors.red.withAlpha((255 * 0.1).round());
                } else if (index == question.correctAnswerIndex) {
                  borderColor = Colors.greenAccent;
                }
              }

              return GestureDetector(
                onTap: () => _answerQuestion(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(
                    question.options[index],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
