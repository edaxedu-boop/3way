import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/debt.dart';

class RegisterDebtScreen extends StatefulWidget {
  const RegisterDebtScreen({super.key});

  @override
  RegisterDebtScreenState createState() => RegisterDebtScreenState();
}

class RegisterDebtScreenState extends State<RegisterDebtScreen> {
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
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFF122E2A)
                  : Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFF122E2A)
                    : Colors.orange,
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
      final newDebt = Debt(
        title: _titleController.text,
        totalAmount: double.parse(_amountController.text),
        remainingAmount: double.parse(_amountController.text),
        date: _selectedDate,
      );
      try {
        await dbHelper.insertDebt(newDebt);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deuda registrada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar la deuda: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final onBackgroundColor = isDarkMode
        ? Colors.white
        : const Color(0xFF122E2A);
    final surfaceColor = isDarkMode
        ? const Color(0xFF1A3833)
        : Colors.grey.shade200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Nueva Deuda',
          style: theme.textTheme.titleLarge?.copyWith(color: onBackgroundColor),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onBackgroundColor),
          onPressed: () => Navigator.of(context).pop(false),
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onBackgroundColor,
                ),
                decoration: _buildInputDecoration(
                  'Descripción de la deuda (Ej: Tarjeta de crédito)',
                  surfaceColor,
                  onBackgroundColor,
                ),
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onBackgroundColor,
                ),
                decoration:
                    _buildInputDecoration(
                      'Monto Total de la Deuda',
                      surfaceColor,
                      onBackgroundColor,
                    ).copyWith(
                      prefixText: 'S/ ',
                      prefixStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: onBackgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'El monto debe ser positivo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildDatePicker(context, theme, surfaceColor, onBackgroundColor),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Guardar Deuda'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    Color surfaceColor,
    Color onBackgroundColor,
  ) {
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
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    ThemeData theme,
    Color surfaceColor,
    Color onBackgroundColor,
  ) {
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
                const Icon(
                  Icons.calendar_today,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  'Fecha de Adquisición',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onBackgroundColor,
                  ),
                ),
              ],
            ),
            Text(
              DateFormat.yMMMd('es').format(_selectedDate),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: onBackgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
