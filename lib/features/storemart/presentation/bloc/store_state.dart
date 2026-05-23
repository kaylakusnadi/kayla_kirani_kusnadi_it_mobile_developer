import 'package:equatable/equatable.dart';
import '../../data/product_model.dart';

abstract class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}
class StoreLoading extends StoreState {}
class LoginSuccess extends StoreState { final String token; const LoginSuccess(this.token); }
class AuthError extends StoreState { final String msg; const AuthError(this.msg); }

class DashboardDataState extends StoreState {
  final List<ProductModel> products;
  final List<Map<String, dynamic>> cartItems;
  final String errorMsg;

  const DashboardDataState({
    required this.products,
    required this.cartItems,
    this.errorMsg = "",
  });

  DashboardDataState copyWith({
    List<ProductModel>? products,
    List<Map<String, dynamic>>? cartItems,
    String? errorMsg,
  }) {
    return DashboardDataState(
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [products, cartItems, errorMsg];
}