import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/product_model.dart';
import '../../../../core/database_helper.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.category), backgroundColor: const Color(0xFF222C57)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.network(widget.product.image, height: 200)),
                  const SizedBox(height: 16),
                  Text(widget.product.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('\$${widget.product.price}', style: const TextStyle(fontSize: 18, color: Color(0xFFF24134), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Text(widget.product.description),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { if(quantity > 1) quantity--; })),
                      Text('$quantity', style: const TextStyle(fontSize: 18)),
                      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => quantity++)),
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF222C57)),
              onPressed: () async {
                await DatabaseHelper.instance.addToCart({
                  'product_id': widget.product.id,
                  'product_title': widget.product.title,
                  'product_image': widget.product.image,
                  'category': widget.product.category,
                  'price': widget.product.price,
                  'quantity': quantity,
                  'subtotal': widget.product.price * quantity,
                  'created_at': DateTime.now().toIso8601String(),
                });
                if (mounted) {
                  context.read<StoreBloc>().add(LoadProductsAndCart());
                  Navigator.pop(context);
                }
              },
              child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}