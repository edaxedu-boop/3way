import 'package:flutter/foundation.dart';
import '../helpers/database_helper.dart';

class BalanceProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, double> _balances = {};
  bool _isLoading = false;

  Map<String, double> get balances => _balances;
  bool get isLoading => _isLoading;

  Future<void> fetchBalances() async {
    _isLoading = true;
    notifyListeners();

    _balances = await _dbHelper.getBudgetSummary();

    _isLoading = false;
    notifyListeners();
  }
}
