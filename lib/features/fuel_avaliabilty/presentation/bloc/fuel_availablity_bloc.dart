import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/features/fuel_avaliabilty/domain/usecases/change_diesel_avaliablity_usecase.dart';
import 'package:station_manager/features/fuel_avaliabilty/domain/usecases/change_petrol_avaliablity_usecase.dart';
import 'package:station_manager/features/fuel_avaliabilty/domain/usecases/check_diesel_avaliabilty_usecase.dart';
import 'package:station_manager/features/fuel_avaliabilty/domain/usecases/check_petrol_avaliabilty_usecase.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_event.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_state.dart';
import 'package:station_manager/features/station/presentation/bloc/station_bloc.dart';
import 'package:station_manager/features/station/presentation/bloc/station_event.dart';

class FuelAvailablityBloc
    extends Bloc<FuelAvailabilityEvent, FuelAvailabilityState> {
  final CheckPetrolAvaliabiltyUsecase checkPetrolAvaliabiltyUsecase;
  final CheckDieselAvaliabiltyUsecase checkDieselAvaliabiltyUsecase;
  final ChangePetrolAvaliablityUsecase changePetrolAvaliablityUsecase;
  final ChangeDieselAvaliablityUsecase changeDieselAvaliablityUsecase;
  final StationBloc stationBloc;

  FuelAvailablityBloc({
    required this.checkPetrolAvaliabiltyUsecase,
    required this.checkDieselAvaliabiltyUsecase,
    required this.changePetrolAvaliablityUsecase,
    required this.changeDieselAvaliablityUsecase,
    required this.stationBloc,
  }) : super(FuelAvailabilityInitial()) {
    on<CheckPetrolAvailabilityEvent>(_onCheckPetrolAvailability);
    on<CheckDieselAvailabilityEvent>(_onCheckDieselAvailability);
    on<ChangePetrolAvailabilityEvent>(_onChangePetrolAvailability);
    on<ChangeDieselAvailabilityEvent>(_onChangeDieselAvailability);
  }

  Future<void> _onCheckPetrolAvailability(
    CheckPetrolAvailabilityEvent event,
    Emitter<FuelAvailabilityState> emit,
  ) async {
    emit(FuelAvailabilityLoading());
    try {
      final response = await checkPetrolAvaliabiltyUsecase(
        event.stationId,
        event.fuelType,
      );
      emit(FuelAvailabilitySuccess(response));
    } catch (e) {
      emit(FuelAvailabilityError(e.toString()));
    }
  }

  Future<void> _onCheckDieselAvailability(
    CheckDieselAvailabilityEvent event,
    Emitter<FuelAvailabilityState> emit,
  ) async {
    emit(FuelAvailabilityLoading());
    try {
      final response = await checkDieselAvaliabiltyUsecase(
        event.stationId,
        event.fuelType,
      );
      emit(FuelAvailabilitySuccess(response));
    } catch (e) {
      emit(FuelAvailabilityError(e.toString()));
    }
  }

  Future<void> _onChangePetrolAvailability(
    ChangePetrolAvailabilityEvent event,
    Emitter<FuelAvailabilityState> emit,
  ) async {
    emit(FuelAvailabilityLoading());
    try {
      final response = await changePetrolAvaliablityUsecase(
        event.stationId,
        event.fuelType,
      );
      emit(FuelAvailabilitySuccess(response));
      stationBloc.add(GetStationIdEvent(id: event.stationId));
    } catch (e) {
      emit(FuelAvailabilityError(e.toString()));
    }
  }

  Future<void> _onChangeDieselAvailability(
    ChangeDieselAvailabilityEvent event,
    Emitter<FuelAvailabilityState> emit,
  ) async {
    emit(FuelAvailabilityLoading());
    try {
      final response = await changeDieselAvaliablityUsecase(
        event.stationId,
        event.fuelType,
      );
      emit(FuelAvailabilitySuccess(response));
      stationBloc.add(GetStationIdEvent(id: event.stationId));
    } catch (e) {
      emit(FuelAvailabilityError(e.toString()));
    }
  }
}

