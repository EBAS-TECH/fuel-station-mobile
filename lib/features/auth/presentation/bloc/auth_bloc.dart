import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/core/error/failures.dart';
import 'package:station_manager/core/exceptions/app_exceptions.dart'
    hide BadRequestException;
import 'package:station_manager/core/utils/exception_handler.dart';
import 'package:station_manager/core/utils/token_services.dart';
import 'package:station_manager/features/auth/domain/usecase/login_usecase.dart';
import 'package:station_manager/features/auth/domain/usecase/logout_usecase.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final TokenService tokenService;

  static const int _minimumLoadingTime = 1500;

  AuthBloc({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.tokenService,
  }) : super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogOutEvent>(_onLogout);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final stopwatch = Stopwatch()..start();

    try {
      final response = await loginUsecase(event.userName, event.password);

      final userId = response["user"]["id"];
      final token = response["token"] ?? "";
      final userData = response["user"];
      final role = response["user"]["role"] as String;

      await tokenService.saveToken(token);
      await tokenService.saveUserId(userId);
      if (role.toLowerCase() != 'gas_station') {
        emit(AuthFailure(error: "You are not a station manager"));
        await tokenService.clearAll();
        return;
      }
      if (userData["station_approved"] != true) {
        emit(AuthFailure(error: "Station is not verifedd"));
        await tokenService.clearAll();
        return;
      }
      emit(
        AuthLogInSucess(message: "Successfully logged", responseData: userData),
      );
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < _minimumLoadingTime) {
        await Future.delayed(
          Duration(milliseconds: _minimumLoadingTime - elapsed),
        );
      }
    } on BadRequestException catch (e) {
      emit(AuthFailure(error: e.toString()));
    } on UnAuthorizedException catch (e) {
      emit(AuthFailure(error: e.toString()));
    } catch (e) {
      final exception = ExceptionHandler.handleError(e);
      emit(AuthFailure(error: exception.toString()));
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> _onLogout(AuthLogOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await logoutUsecase();
      await tokenService.clearAll();
      emit(AuthSucess(message: "Logout successful"));
    } catch (e) {
      final exception = ExceptionHandler.handleError(e);
      emit(AuthFailure(error: ExceptionHandler.getErrorMessage(exception)));
    }
  }
}

