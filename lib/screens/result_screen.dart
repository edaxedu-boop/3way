import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;

  const ResultScreen({super.key, required this.score, required this.totalQuestions, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final percentage = (score / totalQuestions) * 100;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Resultados del Quiz', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Completado!',
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF30E182)),
              ),
              const SizedBox(height: 20),
              Text(
                'Tu puntuación:',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                '$score / $totalQuestions',
                style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '${percentage.toStringAsFixed(0)}% de aciertos',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              _buildSummaryCard(isDarkMode),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text('Volver a intentar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30E182),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Volver a Aprende', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F222A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((255 * 0.05).round()), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de la Regla 50/30/20',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRuleRow('50%', 'Necesidades', 'Gastos esenciales como vivienda, comida y transporte.', Colors.orangeAccent),
          const Divider(height: 20),
          _buildRuleRow('30%', 'Deseos', 'Gastos no esenciales como hobbies, entretenimiento y salidas.', Colors.blueAccent),
          const Divider(height: 20),
          _buildRuleRow('20%', 'Ahorros e Inversiones', 'Pago de deudas, fondo de emergencia e inversiones.', Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String percentage, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          percentage,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(description, style: GoogleFonts.poppins(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}
