import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/transaction.dart';

class RegisterIncomeScreen extends StatefulWidget {
  const RegisterIncomeScreen({super.key});

  @override
  RegisterIncomeScreenState createState() => RegisterIncomeScreenState();
}

class RegisterIncomeScreenState extends State<RegisterIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF30E182),
                  onPrimary: const Color(0xFF122E2A),
                  onSurface: Theme.of(context).brightness == Brightness.light ? const Color(0xFF122E2A) : Colors.white,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF122E2A) : const Color(0xFF30E182),)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final newTransaction = Transaction(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: 'income', // Specify the type
      );
      try {
        await dbHelper.addTransaction(newTransaction);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar ingreso: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final onBackgroundColor = isDarkMode ? Colors.white : const Color(0xFF122E2A);
    final surfaceColor = isDarkMode ? const Color(0xFF1A3833) : Colors.grey.shade200;

    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Ingreso', style: theme.textTheme.titleLarge?.copyWith(color: onBackgroundColor)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onBackgroundColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                style: theme.textTheme.bodyMedium?.copyWith(color: onBackgroundColor),
                decoration: _buildInputDecoration('Descripción', surfaceColor, onBackgroundColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                style: theme.textTheme.bodyMedium?.copyWith(color: onBackgroundColor),
                decoration: _buildInputDecoration('Monto', surfaceColor, onBackgroundColor).copyWith(
                  prefixText: 'S/ ',
                  prefixStyle: theme.textTheme.bodyMedium?.copyWith(color: onBackgroundColor, fontWeight: FontWeight.bold),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildDatePicker(context, theme, surfaceColor, onBackgroundColor),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Guardar Ingreso'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, Color surfaceColor, Color onBackgroundColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: onBackgroundColor.withAlpha(150)),
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF30E182), width: 2),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, ThemeData theme, Color surfaceColor, Color onBackgroundColor) {
    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF30E182), size: 20),
                const SizedBox(width: 16),
                Text(
                  'Fecha',
                  style: theme.textTheme.bodyMedium?.copyWith(color: onBackgroundColor),
                ),
              ],
            ),
            Text(
              DateFormat.yMMMd('es').format(_selectedDate),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: onBackgroundColor),
            ),
          ],
        ),
      ),
    );
  }
}
