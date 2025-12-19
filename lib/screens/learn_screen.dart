import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Aprende',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildQuizCard(context),
          const SizedBox(height: 24),
          Text(
            'Conceptos Clave',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildLearnCard(
            context: context,
            cardColor: cardColor,
            icon: Icons.savings_outlined,
            iconColor: Colors.blueAccent,
            title: 'Crea un Fondo de Emergencia',
            content: _buildRichText([
              const TextSpan(
                text:
                    'Un fondo de emergencia es un dinero que guardas exclusivamente para gastos inesperados. Piensa en él como tu salvavidas financiero.\n\n',
              ),
              const TextSpan(
                text: '¿Por qué es crucial?\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Evita que te endeudes cuando surge un imprevisto, como una reparación del auto o una emergencia médica. Sin este fondo, es muy probable que termines recurriendo a tarjetas de crédito con intereses altos.\n\n',
              ),
              const TextSpan(
                text: '¿Cuánto ahorrar?\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: 'Lo ideal es tener ahorrados de '),
              const TextSpan(
                text: '3 a 6 meses de tus gastos fijos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    ' (alquiler, comida, transporte, etc.). Comienza con lo que puedas, ¡cada sol suma!',
              ),
            ]),
          ),
          _buildLearnCard(
            context: context,
            cardColor: cardColor,
            icon: Icons.attach_money_outlined,
            iconColor: Colors.greenAccent,
            title: 'Automatiza tus Ahorros',
            content: _buildRichText([
              const TextSpan(
                text:
                    'La forma más efectiva de ahorrar es hacerlo sin pensar. La estrategia se conoce como ',
              ),
              const TextSpan(
                text: '"págate a ti mismo primero".\n\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: '¿Cómo funciona?\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Configura una transferencia automática desde tu cuenta principal a tu cuenta de ahorros. Haz que se ejecute el mismo día que recibes tu sueldo. De esta forma, el dinero del ahorro nunca pasa por tus manos, evitando la tentación de gastarlo.\n\n',
              ),
              const TextSpan(
                text: 'Empieza con un monto pequeño',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    ', como un 5% o 10% de tus ingresos, y auméntalo gradualmente.',
              ),
            ]),
          ),
          _buildLearnCard(
            context: context,
            cardColor: cardColor,
            icon: Icons.credit_card_off_outlined,
            iconColor: Colors.orangeAccent,
            title: 'Evita las Deudas de Tarjeta de Crédito',
            content: _buildRichText([
              const TextSpan(
                text:
                    'Las tarjetas de crédito son una herramienta, no una extensión de tu sueldo. Usarlas mal puede llevar a una espiral de deudas por los intereses.\n\n',
              ),
              const TextSpan(
                text: 'La regla de oro:\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: 'Paga siempre el '),
              const TextSpan(
                text: 'monto total de tu factura',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    ' cada mes. Pagar solo el mínimo es el error más costoso, ya que los intereses se acumulan rápidamente (interés compuesto en tu contra).\n\n',
              ),
              const TextSpan(
                text:
                    'Si ya tienes deudas, prioriza pagar la que tenga la tasa de interés más alta. Esto se conoce como el ',
              ),
              const TextSpan(
                text: '"método avalancha".',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          _buildLearnCard(
            context: context,
            cardColor: cardColor,
            icon: Icons.bar_chart_outlined,
            iconColor: Colors.purpleAccent,
            title: 'Invierte para tu Futuro',
            content: _buildRichText([
              const TextSpan(
                text:
                    'Ahorrar es importante, pero la inflación hace que tu dinero pierda valor con el tiempo. La inversión es la clave para que tu dinero crezca.\n\n',
              ),
              const TextSpan(
                text: 'El poder del Interés Compuesto:\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Albert Einstein lo llamó la octava maravilla del mundo. Significa que ',
              ),
              const TextSpan(
                text: 'ganas intereses sobre tus intereses',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    '. Cuanto antes empieces a invertir, más tiempo tendrá tu dinero para crecer exponencialmente.\n\n',
              ),
              const TextSpan(
                text: 'No necesitas ser un experto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    ' para empezar. Puedes explorar opciones como fondos mutuos, ETFs o incluso aplicaciones de inversión automatizada que se ajustan a tu perfil de riesgo.',
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnCard({
    required BuildContext context,
    required Color cardColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final collapsedTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        iconColor: collapsedTextColor,
        collapsedIconColor: collapsedTextColor,
        children: [content],
      ),
    );
  }

  Widget _buildRichText(List<TextSpan> children) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
          height: 1.5,
        ),
        children: children,
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/quiz');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF30E182),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).round()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Financiero',
              style: GoogleFonts.poppins(
                color: const Color(0xFF122E2A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Conoces la Regla 50/30/20?',
              style: GoogleFonts.poppins(
                color: const Color(0xFF122E2A),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Ponte a prueba',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF122E2A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF122E2A),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
