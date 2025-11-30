import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../helpers/database_helper.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Transaction>> _expenseTransactions;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _expenseTransactions = dbHelper.getTransactions('expense');
    });
  }

  void _addExpense(String title, double amount) async {
    final newTransaction = Transaction(title: title, amount: amount, date: DateTime.now());
    await dbHelper.insertTransaction(newTransaction, 'expense');
    _loadTransactions();
  }

  void _updateExpense(Transaction transaction, String newTitle, double newAmount) async {
    final updatedTransaction = Transaction(
      id: transaction.id,
      title: newTitle,
      amount: newAmount,
      date: transaction.date,
    );
    await dbHelper.updateTransaction(updatedTransaction);
    _loadTransactions();
  }

  void _deleteExpense(int id) async {
    await dbHelper.deleteTransaction(id);
    _loadTransactions();
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (title.isNotEmpty && amount > 0) {
                  _addExpense(title, amount);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExpenseDialog(Transaction transaction) {
    final titleController = TextEditingController(text: transaction.title);
    final amountController = TextEditingController(text: transaction.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = titleController.text;
                final newAmount = double.tryParse(amountController.text) ?? 0.0;
                if (newTitle.isNotEmpty && newAmount > 0) {
                  _updateExpense(transaction, newTitle, newAmount);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este gasto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteExpense(id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Transaction>>(
        future: _expenseTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay gastos registrados.'),
            );
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: const Icon(Icons.money_off, color: Colors.red),
                    title: Text(transaction.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                    subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '-\$${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditExpenseDialog(transaction);
                            } else if (value == 'delete') {
                              _showDeleteConfirmationDialog(transaction.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
