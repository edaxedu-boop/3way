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

  Future<void> _deleteInvestment(int id) async {
    await dbHelper.deleteInvestment(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inversión eliminada con éxito'),
        backgroundColor: Colors.green,
      ),
    );
    refreshData();
  }

  void _showDeleteConfirmationDialog(BuildContext context, int investmentId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta inversión? Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                _deleteInvestment(investmentId);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final onBackgroundColor = isDarkMode
        ? Colors.white
        : const Color(0xFF122E2A);

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
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: Row(
              children: [
                Text(
                  'Historial de Inversiones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final cardColor = isDarkMode ? const Color(0xFF1A3833) : Colors.white;
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
            boxShadow: isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withAlpha((255 * 0.1).round()),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
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
          return const Center(
            child: Text(
              'Aún no has registrado ninguna inversión.',
              style: TextStyle(fontSize: 16),
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
            final cardColor = isDarkMode
                ? const Color(0xFF1A3833)
                : Colors.white;
            final textColor = isDarkMode
                ? Colors.white
                : const Color(0xFF122E2A);

            return Card(
              elevation: isDarkMode ? 0 : 2,
              shadowColor: Colors.black.withAlpha((255 * 0.1).round()),
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onLongPress: () =>
                    _showDeleteConfirmationDialog(context, investment.id!),
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
