import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/core/utils/token_services.dart';
import 'package:station_manager/features/station/domain/usecases/get_station_by_id_usecase.dart';
import 'package:station_manager/features/station/presentation/bloc/station_event.dart';
import 'package:station_manager/features/station/presentation/bloc/station_state.dart';

class StationBloc extends Bloc<StationEvent, StationState> {
  final GetStationByIdUsecase getStationByIdUsecase;
  final TokenService tokenService;

  StationBloc({required this.getStationByIdUsecase, required this.tokenService})
    : super(StationInitial()) {
    on<GetStationIdEvent>(_onGetStation);
  }

  Future<void> _onGetStation(
    GetStationIdEvent event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoading());
    try {
      final response = await getStationByIdUsecase(event.id);

      if (response['data'] == null) {
        emit(StationNotFound(message: "Station not found"));
      } else {
        
        emit(
          StationSuccess(message: "Successfully fetched", response: response),
        );
      }
    } catch (e) {
      emit(StationFailure(error: e.toString()));
    }
  }
}

