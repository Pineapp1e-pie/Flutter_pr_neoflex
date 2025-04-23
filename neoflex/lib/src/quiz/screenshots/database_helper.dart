import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:neoflex/src/quiz/screenshots/product.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db1');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE points (
        id INTEGER PRIMARY KEY,
        value INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price INTEGER NOT NULL,
        imagePath TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');
    await db.execute('''
    CREATE TABLE quiz_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      articleKey TEXT NOT NULL,
      hearts INTEGER NOT NULL
    )
    ''');

    // стартовые значения
    await db.insert('points', {'id': 0, 'value': 0});

    await db.insert('products', {
      'name': 'Чехол для телефона от Neoflex',
      'description': 'Чилойвый чехол для телефона',
      'price': 3,
      'imagePath': 'assets/img/чехол.png',
      'quantity': 5
    });
    await db.insert('products', {
      'name': 'Повербанк Neoflex',
      'description': '',
      'price': 7,
      'imagePath': 'assets/img/повербанк.png',
      'quantity': 3
    });
    await db.insert('products', {
      'name': 'Термос Neoflex',
      'description': '',
      'price': 10,
      'imagePath': 'assets/img/термоз.png',
      'quantity': 2
    });
  }
  Future<void> saveQuizResult(int pointsToAdd) async {
    final db = await instance.database;

    // Получаем текущее значение
    final List<Map<String, dynamic>> result = await db.query(
      'points',
      where: 'id = ?',
      whereArgs: [0],
    );

    int currentPoints = 0;
    if (result.isNotEmpty) {
      currentPoints = result.first['value'] ?? 0;
    } else {
      // Если записи нет — создаём её
      await db.insert('points', {'id': 0, 'value': 0});
    }

    final int newPoints = currentPoints + pointsToAdd;

    await db.update(
      'points',
      {'value': newPoints},
      where: 'id = ?',
      whereArgs: [0],
    );
  }




  Future<int> getPoints() async {
    final db = await instance.database;
    final result = await db.query('points', where: 'id = 0');
    return result.isNotEmpty ? result.first['value'] as int : 0;
  }

  Future<void> updatePoints(int newPoints) async {
    final db = await instance.database;
    await db.update('points', {'value': newPoints}, where: 'id = 0');
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products');

    return result.map((map) {
      return Product(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String,
        price: map['price'] as int,
        imagePath: map['imagePath'] as String,
        quantity: map['quantity'] as int,
      );
    }).toList();
  }

  Future<void> decreaseProductQuantity(int productId) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE products
      SET quantity = quantity - 1
      WHERE id = ?
    ''', [productId]);
  }
  Future<int> insertUser(String email, String password) async {
    final db = await instance.database;

    return await db.insert(
      'users',
      {
        'email': email,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> validateUser(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }
}
