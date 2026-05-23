import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';
import '../../../../core/database_helper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color borwitaNavy = Color(0xFF222C57);
    const Color borwitaRed = Color(0xFFF24134);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: borwitaNavy,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          if (state is StoreLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(borwitaRed),
              ),
            );
          }

          if (state is DashboardDataState) {
            final cartItems = state.cartItems;

            if (cartItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Keranjang belanja Anda masih kosong.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            // 1. Menghitung Subtotal menggunakan data dari kolom SQLite
            double subtotal = 0;
            for (var item in cartItems) {
              final double price = (item['price'] as num).toDouble();
              final int qty = item['quantity'] as int;
              subtotal += price * qty;
            }

            // 2. Logika Aturan Bisnis Borwita: Auto Discount 10% jika total > $200
            double discount = 0;
            if (subtotal > 200.0) {
              discount = subtotal * 0.10;
            }
            double grandTotal = subtotal - discount;

            return Column(
              children: [
                // List Item Keranjang Belanjaan
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final double itemPrice = (item['price'] as num).toDouble();

                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              // Gambar Mini Produk (Menggunakan kolom product_image sesuai lembar soal)
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.network(
                                  item['product_image'] ?? '',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Detail Nama & Harga (Menggunakan kolom product_title)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['product_title'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF010101),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${itemPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: borwitaRed,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Panel Manajemen Quantity via BLoC (Menggunakan kolom product_id)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: borwitaNavy),
                                    onPressed: () async {
                                      await DatabaseHelper.instance.removeFromCart(item['product_id'] as int);
                                      if (context.mounted) {
                                        context.read<StoreBloc>().add(LoadProductsAndCart());
                                      }
                                    },
                                  ),
                                  Text(
                                    '${item['quantity']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: borwitaNavy,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: borwitaNavy),
                                    onPressed: () async {
                                      // Menyusun kembali map untuk fungsi penambahan
                                      await DatabaseHelper.instance.addToCart({
                                        'id': item['product_id'],
                                        'title': item['product_title'],
                                        'price': item['price'],
                                        'image': item['product_image'],
                                        'category': item['category'],
                                        'quantity': 1,
                                      });
                                      if (context.mounted) {
                                        context.read<StoreBloc>().add(LoadProductsAndCart());
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Ringkasan Pembayaran & Panel Kalkulasi Diskon Otomatis 10%
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, -3), blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal Items', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w500, color: borwitaNavy, fontSize: 14),
                          ),
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Promo Borwita (10% Off)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 14)),
                            Text(
                              '-\$${discount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: borwitaNavy)),
                          Text(
                            '\$${grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: borwitaRed),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: borwitaNavy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  'Checkout Berhasil! Terima kasih telah berbelanja di Borwita Mart.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                            // Mengosongkan data keranjang di SQLite pasca checkout sukses
                            DatabaseHelper.instance.clearCart().then((_) {
                              if (context.mounted) {
                                context.read<StoreBloc>().add(LoadProductsAndCart());
                              }
                            });
                          },
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Gagal sinkronisasi data keranjang.'));
        },
      ),
    );
  }
}