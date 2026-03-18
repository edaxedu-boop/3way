import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/investment.dart';
import '../helpers/database_helper.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  InvestmentsScreenState createState() => InvestmentsScreenState();
}

class InvestmentsScreenState extends State<InvestmentsScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Investment>> _investmentsFuture;
  late Future<double> _totalInvestmentFuture;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    setState(() {
      _investmentsFuture = dbHelper.getInvestments();
      _totalInvestmentFuture = dbHelper.getTotalInvestments();
    });
  }

  Future<void> _performDeleteInvestment(int id) async {
    await dbHelper.deleteInvestment(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inversión eliminada permanentemente.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    refreshData();
  }

  Future<bool?> _showConfirmationDialog() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: isDarkMode ? const Color(0xFF2D323E) : Colors.white,
          title: Column(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 50),
              const SizedBox(height: 16),
              Text(
                'Confirmar Eliminación',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar esta inversión?\nEsta acción es permanente y no se puede deshacer.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Eliminar',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final onBackgroundColor = isDarkMode ? Colors.white : const Color(0xFF122E2A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mis Inversiones',
          style: theme.textTheme.titleLarge?.copyWith(color: onBackgroundColor),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTotalInvestmentCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: Row(
              children: [
                Text(
                  'Historial de Inversiones',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildInvestmentsList()),
        ],
      ),
    );
  }

  Widget _buildTotalInvestmentCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF122E2A);
    final formatCurrency = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );

    return FutureBuilder<double>(
      future: _totalInvestmentFuture,
      builder: (context, snapshot) {
        Widget content;
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          content = Center(
            child: Text('Error al cargar total: ${snapshot.error}'),
          );
        } else {
          final totalInvestment = snapshot.data ?? 0.0;
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Valor Total Invertido',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textColor.withAlpha((255 * 0.7).round()),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatCurrency.format(totalInvestment),
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6AE2A6),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.05).round()),
                blurRadius: 10,
              ),
            ],
          ),
          child: content,
        );
      },
    );
  }

  Widget _buildInvestmentsList() {
    final formatCurrency = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );
    return FutureBuilder<List<Investment>>(
      future: _investmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final investments = snapshot.data ?? [];
        if (investments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_down,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aún no has registrado ninguna inversión.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: investments.length,
          itemBuilder: (context, index) {
            final investment = investments[index];
            final theme = Theme.of(context);
            final isDarkMode = theme.brightness == Brightness.dark;
            final cardColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;
            final textColor = isDarkMode ? Colors.white : const Color(0xFF122E2A);

            return Dismissible(
              key: ValueKey(investment.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await _showConfirmationDialog();
              },
              onDismissed: (direction) {
                _performDeleteInvestment(investment.id!);
              },
              background: Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Eliminar',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              child: Card(
                elevation: isDarkMode ? 0 : 2,
                shadowColor: Colors.black.withAlpha((255 * 0.05).round()),
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0x336AE2A6),
                        child: Icon(
                          Icons.trending_up,
                          color: Color(0xFF6AE2A6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              investment.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd('es').format(investment.date),
                              style: GoogleFonts.poppins(
                                color: textColor.withAlpha((255 * 0.6).round()),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatCurrency.format(investment.amount),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6AE2A6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
