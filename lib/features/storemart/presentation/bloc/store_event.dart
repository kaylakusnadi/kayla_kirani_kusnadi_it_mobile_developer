import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();
  @override
  List<Object?> get props => [];
}

class LoginAction extends StoreEvent {
  final String username;
  final String password;
  const LoginAction(this.username, this.password);
}

class LoadProductsAndCart extends StoreEvent {}