import '../domain/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Logika adaptif untuk membaca field kategori baik dari FakeStore maupun Platzi
    String extractedCategory = "General";
    if (json['category'] != null) {
      if (json['category'] is Map) {
        extractedCategory = json['category']['name'] ?? "General";
      } else {
        extractedCategory = json['category'].toString();
      }
    }

    // Logika adaptif untuk membaca image url dari array (Platzi) atau string biasa (FakeStore)
    String extractedImage = "";
    if (json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      extractedImage = json['images'].toString();
    } else if (json['image'] != null) {
      extractedImage = json['image'].toString();
    }

    return ProductModel(
      id: json['id'] as int,
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      category: extractedCategory,
      image: extractedImage,
    );
  }
}