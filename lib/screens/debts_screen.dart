import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../helpers/database_helper.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  DebtsScreenState createState() => DebtsScreenState();
}

class DebtsScreenState extends State<DebtsScreen> {
  late Future<List<Debt>> _debtsFuture;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshDebtData();
  }

  void refreshDebtData() {
    setState(() {
      _debtsFuture = dbHelper.getDebts();
    });
  }

  Future<void> _deleteDebt(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres eliminar esta deuda? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dbHelper.deleteDebt(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deuda eliminada'), backgroundColor: Colors.red),
      );
      refreshDebtData();
    }
  }

  void _showPayDialog(Debt debt) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Abonar a ${debt.title}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto a pagar',
                    prefixText: 'S/ ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese un monto';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Ingrese un número válido';
                    }
                    if (amount <= 0) {
                      return 'El monto debe ser positivo';
                    }
                    if (amount > debt.remainingAmount) {
                      return 'El monto no puede ser mayor a la deuda restante';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  hint: const Text('Pagar desde el sobre...'),
                  initialValue: selectedCategory,
                  items: ['Necesidades', 'Deseos', 'Ahorro'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                  onChanged: (value) {
                    selectedCategory = value;
                  },
                  validator: (value) => value == null ? 'Seleccione una categoría' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(amountController.text);
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    await dbHelper.payDebt(debt.id!, amount, selectedCategory!);
                    if (!mounted) return;
                    navigator.pop(); // Close dialog
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('¡Pago realizado con éxito!'), backgroundColor: Colors.green),
                    );
                    refreshDebtData();
                  } catch (e) {
                     if (!mounted) return;
                      navigator.pop();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", "")), backgroundColor: Colors.red),
                      );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              child: const Text('Confirmar Pago'),
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
    final onCardColor = isDarkMode ? Colors.white : const Color(0xFF122E2A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<List<Debt>>(
        future: _debtsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final debts = snapshot.data ?? [];
          final totalDebt = debts.fold(0.0, (sum, item) => sum + item.remainingAmount);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text('Mis Deudas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: onCardColor)),
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                centerTitle: true,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: _buildTotalDebtCard(totalDebt, onCardColor, isDarkMode),
              ),
              if (debts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent.withAlpha(200)),
                        const SizedBox(height: 20),
                        Text('¡No tienes deudas pendientes!', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                )
              else
                _buildDebtsList(debts, onCardColor, isDarkMode),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalDebtCard(double totalDebt, Color onCardColor, bool isDarkMode) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/', decimalDigits: 2);
    final cardColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((255 * 0.05).round()), blurRadius: 10)],
      ),
      child: Center(
        child: Column(
          children: [
            Text('Deuda Total Pendiente', style: GoogleFonts.poppins(fontSize: 16, color: onCardColor.withAlpha((255 * 0.7).round()))),
            const SizedBox(height: 10),
            Text(
              currencyFormat.format(totalDebt),
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: onCardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtsList(List<Debt> debts, Color onCardColor, bool isDarkMode) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'es_PE', symbol: 'S/', decimalDigits: 2);
    final cardColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final debt = debts[index];
          final double percentage = (debt.totalAmount > 0) ? (debt.totalAmount - debt.remainingAmount) / debt.totalAmount : 0.0;
          
          return Dismissible(
            key: ValueKey(debt.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteDebt(debt.id!),
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
              elevation: 2,
              shadowColor: Colors.black.withAlpha((255 * 0.1).round()),
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(debt.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: onCardColor)),
                        Text(
                          currencyFormat.format(debt.remainingAmount),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFFFD6B6B), fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF30E182)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pagado: ${NumberFormat.percentPattern().format(percentage)}',
                          style: GoogleFonts.poppins(color: onCardColor.withAlpha((255 * 0.6).round())),
                        ),
                        Text(
                          'Total: ${currencyFormat.format(debt.totalAmount)}',
                          style: GoogleFonts.poppins(color: onCardColor.withAlpha((255 * 0.6).round())),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPayDialog(debt),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Abonar'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        childCount: debts.length,
      ),
    );
  }
}
