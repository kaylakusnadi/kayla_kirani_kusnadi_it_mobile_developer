import 'package:flutter_bloc/flutter_bloc.dart';
import 'store_event.dart';
import 'store_state.dart';
import '../../data/store_datasource.dart';
import '../../../../core/database_helper.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreDataSource dataSource;

  StoreBloc(this.dataSource) : super(StoreInitial()) {
    on<LoginAction>((event, emit) async {
      emit(StoreLoading());
      final token = await dataSource.login(event.username, event.password);
      if (token != null) {
        emit(LoginSuccess(token));
      } else {
        emit(const AuthError("Kombinasi Username & Password salah!"));
      }
    });

    on<LoadProductsAndCart>((event, emit) async {
      List<Map<String, dynamic>> currentCart = [];
      try {
        currentCart = await DatabaseHelper.instance.getCartItems();
        if (state is! DashboardDataState) emit(StoreLoading());
        
        final products = await dataSource.fetchProducts();
        emit(DashboardDataState(products: products, cartItems: currentCart));
      } catch (_) {
        emit(DashboardDataState(products: const [], cartItems: currentCart, errorMsg: "Gagal memuat data server"));
      }
    });
  }
}