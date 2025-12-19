import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/debt.dart';
import '../models/investment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance_v2.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedDatabase(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS debts');
      await db.execute('DROP TABLE IF EXISTS investments');
      await db.execute('DROP TABLE IF EXISTS budget_summary');
      await _createTables(db);
      await _seedDatabase(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        type TEXT,
        category TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        totalAmount REAL,
        remainingAmount REAL,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE investments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        transactionId INTEGER,
        FOREIGN KEY (transactionId) REFERENCES transactions(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE budget_summary(
        id INTEGER PRIMARY KEY,
        needs_balance REAL,
        wants_balance REAL,
        savings_balance REAL
      )
    ''');
  }

  Future<void> _seedDatabase(Database db) async {
    await db.insert('budget_summary', {
      'id': 1,
      'needs_balance': 0.0,
      'wants_balance': 0.0,
      'savings_balance': 0.0,
    });
  }

  Future<int> addTransaction(
    Transaction transaction, {
    DatabaseExecutor? txn,
  }) async {
    final db = txn ?? await database;
    if (txn != null) {
      return _addTransactionLogic(transaction, txn);
    } else {
      return (db as Database).transaction((txn) async {
        return _addTransactionLogic(transaction, txn);
      });
    }
  }

  Future<int> _addTransactionLogic(
    Transaction transaction,
    DatabaseExecutor txn,
  ) async {
    final newId = await txn.insert(
      'transactions',
      transaction.toMapWithoutId(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (transaction.type == 'income') {
      final needsAmount = transaction.amount * 0.5;
      final wantsAmount = transaction.amount * 0.3;
      final savingsAmount = transaction.amount * 0.2;
      await txn.rawUpdate(
        '''
        UPDATE budget_summary 
        SET needs_balance = needs_balance + ?,
            wants_balance = wants_balance + ?,
            savings_balance = savings_balance + ?
        WHERE id = 1
      ''',
        [needsAmount, wantsAmount, savingsAmount],
      );
    } else if (transaction.type == 'expense') {
      final summary = await getBudgetSummary(txn: txn);
      final category = transaction.category!;
      double currentBalance;
      String columnToUpdate;
      if (category == 'Necesidades') {
        currentBalance = summary['needs']!;
        columnToUpdate = 'needs_balance';
      } else if (category == 'Deseos') {
        currentBalance = summary['wants']!;
        columnToUpdate = 'wants_balance';
      } else {
        // Ahorro
        currentBalance = summary['savings']!;
        columnToUpdate = 'savings_balance';
      }
      if (currentBalance < transaction.amount) {
        throw Exception('Saldo insuficiente en el sobre "$category".');
      }
      await txn.rawUpdate(
        '''
        UPDATE budget_summary SET $columnToUpdate = $columnToUpdate - ? WHERE id = 1
      ''',
        [transaction.amount],
      );
    }
    return newId;
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await _deleteTransactionLogic(id, txn);
    });
  }

  Future<void> _deleteTransactionLogic(int id, DatabaseExecutor txn) async {
    final transactions = await txn.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (transactions.isEmpty) {
      return;
    }

    final transaction = Transaction.fromMap(transactions.first);

    if (transaction.type == 'income') {
      final needsAmount = transaction.amount * 0.5;
      final wantsAmount = transaction.amount * 0.3;
      final savingsAmount = transaction.amount * 0.2;
      await txn.rawUpdate(
        '''
        UPDATE budget_summary 
        SET needs_balance = needs_balance - ?,
            wants_balance = wants_balance - ?,
            savings_balance = savings_balance - ?
        WHERE id = 1
      ''',
        [needsAmount, wantsAmount, savingsAmount],
      );
    } else if (transaction.type == 'expense') {
      final category = transaction.category!;
      String columnToUpdate;
      if (category == 'Necesidades') {
        columnToUpdate = 'needs_balance';
      } else if (category == 'Deseos') {
        columnToUpdate = 'wants_balance';
      } else {
        columnToUpdate = 'savings_balance';
      }
      await txn.rawUpdate(
        'UPDATE budget_summary SET $columnToUpdate = $columnToUpdate + ? WHERE id = 1',
        [transaction.amount],
      );
    }
    await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getBudgetSummary({DatabaseExecutor? txn}) async {
    final db = txn ?? await database;
    final result = await db.query(
      'budget_summary',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      final summary = result.first;
      return {
        'needs': (summary['needs_balance'] as num).toDouble(),
        'wants': (summary['wants_balance'] as num).toDouble(),
        'savings': (summary['savings_balance'] as num).toDouble(),
      };
    }
    return {'needs': 0.0, 'wants': 0.0, 'savings': 0.0};
  }

  Future<void> insertDebt(Debt debt) async {
    final db = await database;
    await db.insert(
      'debts',
      debt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> payDebt(int debtId, double amount, String category) async {
    final db = await database;
    await db.transaction((txn) async {
      final debts = await txn.query(
        'debts',
        where: 'id = ?',
        whereArgs: [debtId],
      );
      if (debts.isEmpty) throw Exception("Deuda no encontrada para pagar.");
      final debt = Debt.fromMap(debts.first);
      final newRemainingAmount = debt.remainingAmount - amount;
      await addTransaction(
        Transaction(
          title: 'Abono a deuda: ${debt.title}',
          amount: amount,
          date: DateTime.now(),
          type: 'expense',
          category: category,
        ),
        txn: txn,
      );
      if (newRemainingAmount <= 0) {
        await txn.delete('debts', where: 'id = ?', whereArgs: [debtId]);
      } else {
        await txn.update(
          'debts',
          {'remainingAmount': newRemainingAmount},
          where: 'id = ?',
          whereArgs: [debtId],
        );
      }
    });
  }

  Future<List<Debt>> getDebts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      orderBy: 'date DESC',
    );
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<void> deleteDebt(int id) async {
    final db = await database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertInvestment(
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      final transaction = Transaction(
        title: 'Inversión: $title',
        amount: amount,
        date: date,
        type: 'expense',
        category: category,
      );
      final newTransactionId = await _addTransactionLogic(transaction, txn);
      final newInvestment = Investment(
        title: title,
        amount: amount,
        date: date,
        transactionId: newTransactionId,
      );
      await txn.insert(
        'investments',
        newInvestment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<Investment>> getInvestments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Investment.fromMap(maps[i]));
  }

  Future<void> deleteInvestment(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      final investments = await txn.query(
        'investments',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (investments.isEmpty) {
        return;
      }
      final investment = Investment.fromMap(investments.first);
      await _deleteTransactionLogic(investment.transactionId, txn);
      await txn.delete('investments', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<double> getTotalInvestments() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM investments',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getSummary() async {
    final budgetSummary = await getBudgetSummary();
    final totalBalance =
        budgetSummary['needs']! +
        budgetSummary['wants']! +
        budgetSummary['savings']!;
    final db = await database;
    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = \'income\'',
    );
    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = \'expense\'',
    );
    final income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;
    return {'total': totalBalance, 'income': income, 'expense': expense};
  }

  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }
}
