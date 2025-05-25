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

  bool _petrolAvailable = false;
  bool _dieselAvailable = false;

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
    emit(FuelAvailabilityLoading(isPetrolLoading: true));
    try {
      final response = await checkPetrolAvaliabiltyUsecase(
        event.stationId,
        event.fuelType,
      );

      bool petrolAvailable;
      if (response['data'] is bool) {
        petrolAvailable = response['data'] as bool;
      } else if (response['data'] is Map &&
          response['data']['available'] != null) {
        petrolAvailable = response['data']['available'] as bool;
      } else {
        throw Exception('Invalid response format for petrol availability');
      }

      _petrolAvailable = petrolAvailable;
      emit(
        FuelAvailabilityUpdated(
          petrolAvailable: _petrolAvailable,
          dieselAvailable: _dieselAvailable,
        ),
      );
    } catch (e) {
      emit(
        FuelAvailabilityError(
          e.toString(),
          isPetrolError: true,
          petrolAvailable: _petrolAvailable,
          dieselAvailable: _dieselAvailable,
        ),
      );
    }
  }

  Future<void> _onCheckDieselAvailability(
    CheckDieselAvailabilityEvent event,
    Emitter<FuelAvailabilityState> emit,
  ) async {
    emit(FuelAvailabilityLoading(isDieselLoading: true));
    try {
      final response = await checkDieselAvaliabiltyUsecase(
        event.stationId,
        event.fuelType,
      );

      bool dieselAvailable;
      if (response['data'] is bool) {
        dieselAvailable = response['data'] as bool;
      } else if (response['data'] is Map &&
          response['data']['available'] != null) {
        dieselAvailable = response['data']['available'] as bool;
      } else {
        throw Exception('Invalid response format for diesel availability');
      }

      _dieselAvailable = dieselAvailable;
      emit(
        FuelAvailabilityUpdated(
          petrolAvailable: _petrolAvailable,
          dieselAvailable: _dieselAvailable,
        ),
      );
    } catch (e) {
      emit(
        FuelAvailabilityError(
          e.toString(),
          isPetrolError: false,
          petrolAvailable: _petrolAvailable,
          dieselAvailable: _dieselAvailable,
        ),
      );
    }
  }

  Future<void> _onChangePetrolAvailability(
    ChangePetrolAvailabilityEvent event,
    Emitter<FuelAvailabilityState> emit,
  ) async {
    emit(FuelAvailabilityLoading(isPetrolLoading: true));
    try {
      final response = await changePetrolAvaliablityUsecase(
        event.stationId,
        event.fuelType,
      );

      bool petrolAvailable;
      if (response['data'] is bool) {
        petrolAvailable = response['data'] as bool;
      } else if (response['data'] is Map &&
          response['data']['available'] != null) {
        petrolAvailable = response['data']['available'] as bool;
      } else if (response['message']?.toLowerCase().contains('success') == true) {
        petrolAvailable = !_petrolAvailable;
      } else {
        throw Exception(
          'Invalid response format for petrol availability change',
        );
      }

      _petrolAvailable = petrolAvailable;
      emit(
        FuelAvailabilityUpdated(
          petrolAvailable: _petrolAvailable,
          dieselAvailable: _dieselAvailable,
        ),
      );
      stationBloc.add(GetStationIdEvent(id: event.stationId));
    } catch (e) {
      if (e.toString().toLowerCase().contains('success')) {
        _petrolAvailable = !_petrolAvailable;
        emit(
          FuelAvailabilityUpdated(
            petrolAvailable: _petrolAvailable,
            dieselAvailable: _dieselAvailable,
          ),
        );
        stationBloc.add(GetStationIdEvent(id: event.stationId));
      } else {
        emit(
          FuelAvailabilityError(
            e.toString(),
            isPetrolError: true,
            petrolAvailable: _petrolAvailable,
            dieselAvailable: _dieselAvailable,
          ),
        );
      }
    }
  }

  Future<void> _onChangeDieselAvailability(
    ChangeDieselAvailabilityEvent event,
    Emitter<FuelAvailabilityState> emit,
  ) async {
    emit(FuelAvailabilityLoading(isDieselLoading: true));
    try {
      final response = await changeDieselAvaliablityUsecase(
        event.stationId,
        event.fuelType,
      );

      bool dieselAvailable;
      if (response['data'] is bool) {
        dieselAvailable = response['data'] as bool;
      } else if (response['data'] is Map &&
          response['data']['available'] != null) {
        dieselAvailable = response['data']['available'] as bool;
      } else if (response['message']?.toLowerCase().contains('success') == true) {
        dieselAvailable = !_dieselAvailable;
      } else {
        throw Exception(
          'Invalid response format for diesel availability change',
        );
      }

      _dieselAvailable = dieselAvailable;
      emit(
        FuelAvailabilityUpdated(
          petrolAvailable: _petrolAvailable,
          dieselAvailable: _dieselAvailable,
        ),
      );
      stationBloc.add(GetStationIdEvent(id: event.stationId));
    } catch (e) {
      if (e.toString().toLowerCase().contains('success')) {
        _dieselAvailable = !_dieselAvailable;
        emit(
          FuelAvailabilityUpdated(
            petrolAvailable: _petrolAvailable,
            dieselAvailable: _dieselAvailable,
          ),
        );
        stationBloc.add(GetStationIdEvent(id: event.stationId));
      } else {
        emit(
          FuelAvailabilityError(
            e.toString(),
            isPetrolError: false,
            petrolAvailable: _petrolAvailable,
            dieselAvailable: _dieselAvailable,
          ),
        );
      }
    }
  }
}

