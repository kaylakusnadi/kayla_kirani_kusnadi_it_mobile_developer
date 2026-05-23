import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';
import '../../data/product_model.dart';
import 'product_detail_screen.dart';
import '../../../../core/database_helper.dart'; // IMPORT DATABASE HELPER

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
    const Color borwitaNavy = Color(0xFF222C57);
    const Color borwitaRed = Color(0xFFF24134);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Borwita Mart'),
        backgroundColor: borwitaNavy,
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
                      prefixIcon: Icon(Icons.search, color: borwitaNavy),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_alt, color: borwitaNavy, size: 28),
                  tooltip: "Filter Category",
                  onSelected: (v) => setState(() => selectedCategory = v),
                  itemBuilder: (_) => ['All', 'Clothes', 'Electronics', 'Furniture', 'Shoes', 'Others']
                      .map((e) => PopupMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.swap_vert, color: borwitaNavy, size: 28),
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
                      valueColor: AlwaysStoppedAnimation<Color>(borwitaRed),
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
                      childAspectRatio: 0.67, // Diubah ke 0.67 agar pas menampung tombol aksi baru di bagian bawah
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
                              // Render Gambar
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
                                      item.category,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Row untuk Harga dan Tombol Add to Cart Resmi
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: borwitaRed,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        // TOMBOL ADD TO CART YANG SUDAH TERINTEGRASI BLoC + SQLITE
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.add_shopping_cart, color: borwitaNavy, size: 22),
                                          onPressed: () async {
                                            // 1. Simpan ke database SQLite lokal dengan skema Borwita
                                            await DatabaseHelper.instance.addToCart({
                                              'id': item.id,
                                              'title': item.title,
                                              'price': item.price,
                                              'image': item.image,
                                              'category': item.category,
                                            });

                                            // 2. Picu pembaruan state global BLoC
                                            if (context.mounted) {
                                              context.read<StoreBloc>().add(LoadProductsAndCart());
                                              
                                              // Memunculkan snackbar penanda sukses
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: borwitaNavy,
                                                  content: Text(
                                                    '${item.title} ditambahkan!',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  duration: const Duration(milliseconds: 700),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
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