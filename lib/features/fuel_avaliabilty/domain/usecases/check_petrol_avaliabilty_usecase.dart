import 'package:station_manager/features/fuel_avaliabilty/domain/repositories/fuel_avaliabilty_repository.dart';

class CheckPetrolAvaliabiltyUsecase {
  final FuelAvaliabiltyRepository fuelAvaliabiltyRepository;

  CheckPetrolAvaliabiltyUsecase({required this.fuelAvaliabiltyRepository});

  Future<Map<String, dynamic>> call(String stationId, String fuelType) {
    return fuelAvaliabiltyRepository.checkPetrolFuelAvaliabilty(
      stationId,
      fuelType,
    );
  }
}

