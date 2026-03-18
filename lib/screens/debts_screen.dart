import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../helpers/database_helper.dart';
import '../providers/balance_provider.dart';

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

  Future<void> _performDeleteDebt(int id) async {
    await dbHelper.deleteDebt(id);
    if (!mounted) return;
    Provider.of<BalanceProvider>(context, listen: false).fetchBalances();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deuda eliminada permanentemente.'),
        backgroundColor: Colors.red,
      ),
    );
    refreshDebtData();
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
            '¿Estás seguro de que quieres eliminar esta deuda?\nEsta acción es permanente y no se puede deshacer.',
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

  void _showPayDialog(Debt debt) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF2D323E)
              : Colors.white,
          title: Center(
            child: Text(
              'Abonar a ${debt.title}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Monto a pagar',
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: theme.colorScheme.primary,
                      ),
                      prefixText: 'S/ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                        return 'El monto no puede superar la deuda restante (${NumberFormat.currency(locale: 'es_PE', symbol: 'S/').format(debt.remainingAmount)})';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    hint: const Text('Pagar desde el sobre...'),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['Necesidades', 'Deseos', 'Ahorro']
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => selectedCategory = value,
                    validator: (value) =>
                        value == null ? 'Seleccione un sobre' : null,
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Confirmar Pago'),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final amount = double.parse(amountController.text);
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final balanceProvider = Provider.of<BalanceProvider>(
                          context,
                          listen: false,
                        );

                        try {
                          await dbHelper.payDebt(
                            debt.id!,
                            amount,
                            selectedCategory!,
                          );
                          if (!mounted) return;

                          await balanceProvider.fetchBalances();

                          navigator.pop(); // Close dialog
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: const Text('¡Pago realizado con éxito!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          refreshDebtData();
                        } catch (e) {
                          if (!mounted) return;
                          navigator.pop();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceFirst("Exception: ", ""),
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
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
          final totalDebt = debts.fold(
            0.0,
            (sum, item) => sum + item.remainingAmount,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  'Mis Deudas',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: onCardColor,
                  ),
                ),
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
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.greenAccent.withAlpha(200),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '¡No tienes deudas pendientes!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
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

  Widget _buildTotalDebtCard(
    double totalDebt,
    Color onCardColor,
    bool isDarkMode,
  ) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );
    final cardColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              'Deuda Total Pendiente',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: onCardColor.withAlpha((255 * 0.7).round()),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              currencyFormat.format(totalDebt),
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: onCardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtsList(List<Debt> debts, Color onCardColor, bool isDarkMode) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );
    final cardColor = isDarkMode ? const Color(0xFF1F222A) : Colors.white;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final debt = debts[index];
        final double percentage = (debt.totalAmount > 0)
            ? (debt.totalAmount - debt.remainingAmount) / debt.totalAmount
            : 0.0;

        return Dismissible(
          key: ValueKey(debt.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await _showConfirmationDialog();
          },
          onDismissed: (direction) {
            _performDeleteDebt(debt.id!);
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
            elevation: 2,
            shadowColor: Colors.black.withAlpha((255 * 0.1).round()),
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        debt.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: onCardColor,
                        ),
                      ),
                      Text(
                        currencyFormat.format(debt.remainingAmount),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFD6B6B),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF30E182),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pagado: ${NumberFormat.percentPattern().format(percentage)}',
                        style: GoogleFonts.poppins(
                          color: onCardColor.withAlpha((255 * 0.6).round()),
                        ),
                      ),
                      Text(
                        'Total: ${currencyFormat.format(debt.totalAmount)}',
                        style: GoogleFonts.poppins(
                          color: onCardColor.withAlpha((255 * 0.6).round()),
                        ),
                      ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }, childCount: debts.length),
    );
  }
}
