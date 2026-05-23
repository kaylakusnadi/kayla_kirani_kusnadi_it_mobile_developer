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

  // Mengambil semua item di keranjang
  Future<List<Map<String, dynamic>>> getCartItems() async {
    Database db = await instance.database;
    return await db.query('cart_items');
  }

  // Menambah atau memperbarui item di keranjang (Super Safe Mode)
  Future<int> addToCart(Map<String, dynamic> product) async {
    Database db = await instance.database;
    
    // Antispasi variasi key ID dari model objek maupun map mentah
    int prodId = product['product_id'] ?? product['id'];
    
    // Proteksi konversi tipe data num/int/double dari API agar tidak crash di APK Rilis
    double prodPrice = 0.0;
    if (product['price'] != null) {
      prodPrice = (product['price'] as num).toDouble();
    }

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
        'product_id': prodId,
        'product_title': product['product_title'] ?? product['title'] ?? 'No Title',
        'product_image': product['product_image'] ?? product['image'] ?? '',
        'category': product['category'] ?? 'General',
        'price': prodPrice,
        'quantity': 1,
        'subtotal': prodPrice,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Mengurangi kuantitas atau menghapus jika kuantitas = 1
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

  // Mengosongkan keranjang belanja setelah checkout sukses
  Future<int> clearCart() async {
    Database db = await instance.database;
    return await db.delete('cart_items');
  }
}