class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSucess extends AuthState {
  final Map<String, dynamic>? responseData;
  final String message;

  AuthSucess({this.responseData, required this.message});
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});
}

