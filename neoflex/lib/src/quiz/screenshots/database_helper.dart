import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:neoflex/src/quiz/screenshots/product.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
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
    password TEXT NOT NULL,
    points INTEGER NOT NULL DEFAULT 0
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
    user_id INTEGER NOT NULL,
    articleKey TEXT NOT NULL,
    hearts INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    UNIQUE(user_id, articleKey) -- один результат на пользователя на одну статью
)
    ''');

    // стартовые значения

    await db.insert('products', {
      'name': 'Чехол для телефона от Neoflex',
      'description': 'Чиловый повербанк',
      'price': 3,
      'imagePath': 'assets/img/повербанк.png',
      'quantity': 5
    });
    await db.insert('products', {
      'name': 'Повербанк Neoflex',
      'description': '',
      'price': 5,
      'imagePath': 'assets/img/колонка.png',
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
  Future<bool> isUserExists(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
  Future<void> saveQuizResult(String email, int pointsToAdd) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      columns: ['points'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      final int currentPoints = result.first['points'] as int;
      final int newPoints = currentPoints + pointsToAdd;


      await db.update(
        'users',
        {'points': newPoints},
        where: 'email = ?',
        whereArgs: [email],
      );
    }
  }


  Future<int> getPoints(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      columns: ['points'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first['points'] as int : 0;
  }


  Future<void> updatePoints(String email, int newPoints) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'points': newPoints},
      where: 'email = ?',
      whereArgs: [email],
    );
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
        'points': 0,
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


  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, int? limit}) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
  }
}
