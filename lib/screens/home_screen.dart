import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen Financiero',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 24.0),
            FutureBuilder<double>(
              future: dbHelper.getTotal('income'),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0.0;
                return _buildSummaryCard(context, 'Ingresos Totales', '\$${total.toStringAsFixed(2)}', Icons.attach_money, Colors.green);
              },
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<double>(
              future: dbHelper.getTotal('expense'),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0.0;
                return _buildSummaryCard(context, 'Gastos Totales', '\$${total.toStringAsFixed(2)}', Icons.money_off, Colors.red);
              },
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<double>(
              future: dbHelper.getTotal('debt'),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0.0;
                return _buildSummaryCard(context, 'Deuda Total', '\$${total.toStringAsFixed(2)}', Icons.receipt, Colors.orange);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount, IconData icon, Color color) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40.0, color: color),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 4.0),
                Text(amount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
