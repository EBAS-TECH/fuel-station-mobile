import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/core/exceptions/app_exceptions.dart';
import 'package:station_manager/core/utils/exception_handler.dart';
import 'package:station_manager/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:station_manager/features/user/presentation/bloc/user_event.dart';
import 'package:station_manager/features/user/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserByIdUsecase getUserByIdUsecase;

  UserBloc({required this.getUserByIdUsecase}) : super(UserInitial()) {
    on<GetUserByIdEvent>(_getUserById);
  }

  Future<void> _getUserById(
    GetUserByIdEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final response = await getUserByIdUsecase(event.userId);

      if (response['data'] == null) {
        emit(UserNotFound(message: "User not found"));
      } else {
        emit(UserSuccess(response, message: "Successfully fetched"));
      }
    } catch (e) {
      final exception = ExceptionHandler.handleError(e);
      _handleError(exception, emit);
    }
  }

  void _handleError(AppException exception, Emitter<UserState> emit) {
    switch (exception.runtimeType) {
      case NotFoundException:
        emit(UserNotFound(message: exception.message));
        break;
      case UnAuthorizedException:
        emit(UserUnauthorized(message: exception.message));
        break;
      case BadRequestException:
        emit(UserValidationError(message: exception.message));
        break;
      case ConflictException:
        emit(UserConflictError(message: exception.message));
        break;
      default:
        emit(UserError(exception.message));
    }
  }
}

