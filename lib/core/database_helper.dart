import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'storemart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // MEMBUAT TABEL DAN KOLOM 100% SESUAI LEMBAR SOAL BORWITA
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        product_title TEXT,
        product_image TEXT,
        category TEXT,
        price REAL,
        quantity INTEGER,
        subtotal REAL,
        created_at TEXT
      )
    ''');
  }

  // 1. Mengambil data item keranjang
  Future<List<Map<String, dynamic>>> getCartItems() async {
    Database db = await instance.database;
    return await db.query('cart_items');
  }

  // 2. Menambah produk ke keranjang (Atau update jika product_id sudah ada)
  Future<int> addToCart(Map<String, dynamic> product) async {
    Database db = await instance.database;
    int prodId = product['id'];
    double prodPrice = (product['price'] as num).toDouble();
    
    List<Map<String, dynamic>> maps = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [prodId],
    );

    if (maps.isNotEmpty) {
      int currentQty = maps.first['quantity'] as int;
      int newQty = currentQty + 1;
      return await db.update(
        'cart_items',
        {
          'quantity': newQty,
          'subtotal': prodPrice * newQty
        },
        where: 'product_id = ?',
        whereArgs: [prodId],
      );
    } else {
      return await db.insert('cart_items', {
        'product_id': product['id'],
        'product_title': product['title'],
        'product_image': product['image'],
        'category': product['category'] ?? 'General',
        'price': prodPrice,
        'quantity': 1,
        'subtotal': prodPrice,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // 3. Mengurangi quantity produk
  Future<int> removeFromCart(int productId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (maps.isNotEmpty) {
      int currentQty = maps.first['quantity'] as int;
      double price = (maps.first['price'] as num).toDouble();
      
      if (currentQty > 1) {
        int newQty = currentQty - 1;
        return await db.update(
          'cart_items',
          {
            'quantity': newQty,
            'subtotal': price * newQty
          },
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      } else {
        return await db.delete('cart_items', where: 'product_id = ?', whereArgs: [productId]);
      }
    }
    return 0;
  }

  // 4. Mengosongkan keranjang
  Future<int> clearCart() async {
    Database db = await instance.database;
    return await db.delete('cart_items');
  }
}