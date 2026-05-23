import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';
import '../../data/product_model.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String query = "";
  String selectedCategory = "All";
  String sortOrder = "None";

  @override
  void initState() {
    super.initState();
    // Memicu sinkronisasi data produk dari API sesaat setelah layar dimuat
    context.read<StoreBloc>().add(LoadProductsAndCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Fake Storemart'),
        backgroundColor: const Color(0xFF222C57),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Menghilangkan panah back otomatis
      ),
      body: Column(
        children: [
          // Baris Panel Pencarian, Filter Kategori, dan Pengurutan Harga
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search product...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF222C57)),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_alt, color: Color(0xFF222C57), size: 28),
                  tooltip: "Filter Category",
                  onSelected: (v) => setState(() => selectedCategory = v),
                  itemBuilder: (_) => ['All', 'Clothes', 'Electronics', 'Furniture', 'Shoes', 'Others']
                      .map((e) => PopupMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.swap_vert, color: Color(0xFF222C57), size: 28),
                  tooltip: "Sort Price",
                  onSelected: (v) => setState(() => sortOrder = v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'LowHigh', child: Text('Price: Low → High')),
                    const PopupMenuItem(value: 'HighLow', child: Text('Price: High → Low')),
                  ],
                ),
              ],
            ),
          ),
          
          // Area Gridview Utama untuk Merender Daftar Produk
          Expanded(
            child: BlocBuilder<StoreBloc, StoreState>(
              builder: (context, state) {
                if (state is StoreLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF24134)),
                    ),
                  );
                }
                
                if (state is DashboardDataState) {
                  // Logika Pencarian (Title) dan Filter (Category) di sisi Klien
                  List<ProductModel> filtered = state.products.where((p) {
                    final matchQuery = p.title.toLowerCase().contains(query.toLowerCase());
                    final matchCat = selectedCategory == "All" || 
                        p.category.toLowerCase() == selectedCategory.toLowerCase();
                    return matchQuery && matchCat;
                  }).toList();

                  // Logika Pengurutan Nilai Harga (Price Sorting)
                  if (sortOrder == "LowHigh") {
                    filtered.sort((a, b) => a.price.compareTo(b.price));
                  } else if (sortOrder == "HighLow") {
                    filtered.sort((a, b) => b.price.compareTo(a.price));
                  }

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Produk tidak ditemukan.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: item),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Render Gambar dengan Fitur Interseptor Kegagalan Jaringan
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  width: double.infinity,
                                  child: Image.network(
                                    item.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image, 
                                      color: Colors.grey, 
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1, thickness: 1),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF010101),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFFF24134),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.category,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                
                return const Center(child: Text('Gagal sinkronisasi data server.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}