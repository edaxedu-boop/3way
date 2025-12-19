import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/database_helper.dart';
import '../models/transaction.dart';
import '../providers/balance_provider.dart';
import '../providers/navigation_provider.dart';
import 'register_income_screen.dart';
import 'register_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper();
  Future<List<dynamic>>? _loadPageDataFuture;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Fetch balances via the provider, not listening here because it's a one-time action
    Provider.of<BalanceProvider>(context, listen: false).fetchBalances();
    // Load other page-specific data
    _loadPageSpecificData();
  }

  Future<String?> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<void> _loadPageSpecificData() async {
    setState(() {
      _loadPageDataFuture = Future.wait([
        dbHelper.getRecentTransactions(),
        _getUserName(),
      ]);
    });
  }

  Future<void> _handleRefresh() async {
    // Both futures will run concurrently
    await Future.wait([
      Provider.of<BalanceProvider>(context, listen: false).fetchBalances(),
      _loadPageSpecificData(),
    ]);
  }

  void _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result == true) {
      _handleRefresh();
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      await dbHelper.deleteTransaction(transaction.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transacción eliminada'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'DESHACER',
            textColor: Colors.white,
            onPressed: () {
              _undoDelete(transaction);
            },
          ),
        ),
      );
      _handleRefresh(); // Refresh data after deletion
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _undoDelete(Transaction transaction) async {
    try {
      await dbHelper.addTransaction(transaction);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción restaurada'),
          backgroundColor: Colors.green,
        ),
      );
      _handleRefresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al restaurar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        backgroundColor: theme.scaffoldBackgroundColor,
        child: FutureBuilder<List<dynamic>>(
          future: _loadPageDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildErrorState(
                'Error al cargar datos: ${snapshot.error}',
              );
            } else if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!.length < 2) {
              return _buildErrorState('No se encontraron datos.');
            }

            final recentTransactions = snapshot.data![0] as List<Transaction>;
            final userName = snapshot.data![1] as String?;

            return Consumer<BalanceProvider>(
              builder: (context, balanceProvider, child) {
                if (balanceProvider.isLoading && balanceProvider.balances.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final summary = balanceProvider.balances;
                final needs = summary['needs'] ?? 0.0;
                final wants = summary['wants'] ?? 0.0;
                final savings = summary['savings'] ?? 0.0;
                final totalBalance = needs + wants + savings;

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _buildAppBar(context, userName),
                  ],
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTotalBalanceCard(
                          context,
                          totalBalance,
                          formatCurrency,
                        ),
                        const SizedBox(height: 24),
                        _buildBudgetCards(context, summary, formatCurrency),
                        const SizedBox(height: 24),
                        _buildActionButtons(context, theme),
                        const SizedBox(height: 24),
                        _buildBudgetDistributionChart(context, summary),
                        const SizedBox(height: 32),
                        _buildRecentActivity(context, theme, recentTransactions),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, String? userName) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola,',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(
                userName ?? 'Usuario',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, size: 28),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
      pinned: true,
      floating: true,
    );
  }

  Widget _buildTotalBalanceCard(
    BuildContext context,
    double totalBalance,
    NumberFormat formatCurrency,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final cardDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [
          isDarkMode ? const Color(0xFF2D323E) : Colors.blueGrey.shade700,
          isDarkMode ? const Color(0xFF1A1D25) : Colors.blueGrey.shade900,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((255 * 0.15).round()),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance General',
            style: GoogleFonts.poppins(
              color: Colors.white.withAlpha((255 * 0.7).round()),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency.format(totalBalance),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCards(
    BuildContext context,
    Map<String, double> summary,
    NumberFormat formatCurrency,
  ) {
    final needs = summary['needs'] ?? 0.0;
    final wants = summary['wants'] ?? 0.0;
    final savings = summary['savings'] ?? 0.0;

    return Column(
      children: [
        _budgetCard(
          'Necesidades (50%)',
          needs,
          formatCurrency,
          Colors.orangeAccent,
        ),
        const SizedBox(height: 16),
        _budgetCard('Deseos (30%)', wants, formatCurrency, Colors.blueAccent),
        const SizedBox(height: 16),
        _budgetCard(
          'Ahorro (20%)',
          savings,
          formatCurrency,
          Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _budgetCard(
    String title,
    double amount,
    NumberFormat format,
    Color color,
  ) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1F222A)
        : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).round()),
            blurRadius: 10,
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Text(
            format.format(amount),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    final primaryColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1A3833)
        : const Color(0xFFE3F4F0);
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionButton(
          context,
          icon: Icons.add_rounded,
          label: 'Ingreso',
          screen: const RegisterIncomeScreen(),
          primaryColor: primaryColor,
        ),
        _actionButton(
          context,
          icon: Icons.remove_rounded,
          label: 'Gasto',
          screen: const RegisterExpenseScreen(),
          primaryColor: primaryColor,
        ),
        _actionButton(
          context,
          icon: Icons.payment_rounded,
          label: 'Deudas',
          onTap: () => navigationProvider.setIndex(1),
          primaryColor: primaryColor,
        ),
        _actionButton(
          context,
          icon: Icons.show_chart_rounded,
          label: 'Invertir',
          onTap: () => navigationProvider.setIndex(3),
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? screen,
    VoidCallback? onTap,
    required Color primaryColor,
  }) {
    return Column(
      children: [
        Material(
          color: primaryColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () {
              if (screen != null) {
                _navigateAndRefresh(screen);
              } else if (onTap != null) {
                onTap();
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Icon(icon, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBudgetDistributionChart(
    BuildContext context,
    Map<String, double> summary,
  ) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1F222A)
        : Colors.white;

    final needs = summary['needs'] ?? 0.0;
    final wants = summary['wants'] ?? 0.0;
    final savings = summary['savings'] ?? 0.0;
    final total = needs + wants + savings;

    final List<PieChartSectionData> sections;
    if (total > 0) {
      sections = [
        PieChartSectionData(
          color: Colors.orangeAccent,
          value: needs,
          title: '${(needs / total * 100).toStringAsFixed(0)}%',
          radius: 25,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        PieChartSectionData(
          color: Colors.blueAccent,
          value: wants,
          title: '${(wants / total * 100).toStringAsFixed(0)}%',
          radius: 25,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        PieChartSectionData(
          color: Colors.greenAccent,
          value: savings,
          title: '${(savings / total * 100).toStringAsFixed(0)}%',
          radius: 25,
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ];
    } else {
      sections = [
        PieChartSectionData(
          color: Colors.grey.shade400,
          value: 100,
          title: 'N/A',
          radius: 25,
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).round()),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                startDegreeOffset: -90,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribución del Presupuesto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLegend(color: Colors.orangeAccent, text: 'Necesidades'),
                const SizedBox(height: 4),
                _buildLegend(color: Colors.blueAccent, text: 'Deseos'),
                const SizedBox(height: 4),
                _buildLegend(color: Colors.greenAccent, text: 'Ahorro'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.poppins(fontSize: 14)),
      ],
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    ThemeData theme,
    List<Transaction> transactions,
  ) {
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1F222A)
        : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          _buildErrorState('No hay transacciones recientes.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return Dismissible(
                key: ValueKey(tx.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteTransaction(tx);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: _buildTransactionItem(tx, context, cardColor),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
      ],
    );
  }

  Widget _buildTransactionItem(
    Transaction tx,
    BuildContext context,
    Color cardColor,
  ) {
    final isIncome = tx.type == 'income';
    final formatCurrency = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );
    final theme = Theme.of(context);

    IconData iconData;
    Color color;
    String sign;

    if (isIncome) {
      iconData = Icons.keyboard_arrow_down_rounded;
      color = const Color(0xFF30E182);
      sign = '+';
    } else {
      iconData = Icons.keyboard_arrow_up_rounded; // This line was missing
      if (tx.category == 'Necesidades') {
        color = Colors.orangeAccent;
      } else if (tx.category == 'Deseos') {
        color = Colors.blueAccent;
      } else {
        // Ahorro
        color = Colors.greenAccent;
      }
      sign = '-';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).round()),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat.yMMMd('es').format(tx.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '$sign${formatCurrency.format(tx.amount)}',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _handleRefresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
