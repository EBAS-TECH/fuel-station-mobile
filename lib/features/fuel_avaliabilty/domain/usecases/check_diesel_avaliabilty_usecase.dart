import 'package:station_manager/features/fuel_avaliabilty/domain/repositories/fuel_avaliabilty_repository.dart';

class CheckDieselAvaliabiltyUsecase {
  final FuelAvaliabiltyRepository fuelAvaliabiltyRepository;

  CheckDieselAvaliabiltyUsecase({required this.fuelAvaliabiltyRepository});

  Future<Map<String, dynamic>> call(String stationId, String fuelType) {
    return fuelAvaliabiltyRepository.checkDieselFuelAvaliabilty(
      stationId,
      fuelType,
    );
  }
}

