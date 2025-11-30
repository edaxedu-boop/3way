import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        type TEXT
      )
    ''');
  }

  Future<int> insertTransaction(Transaction transaction, String type) async {
    final db = await database;
    final map = transaction.toMap();
    map['type'] = type;
    return await db.insert('transactions', map);
  }
  
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Transaction>> getTransactions(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
    );

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<double> getTotal(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }
}
