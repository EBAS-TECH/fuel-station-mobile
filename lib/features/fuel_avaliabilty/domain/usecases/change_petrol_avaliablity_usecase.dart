import 'package:station_manager/features/fuel_avaliabilty/domain/repositories/fuel_avaliabilty_repository.dart';

class ChangePetrolAvaliablityUsecase {
  final FuelAvaliabiltyRepository fuelAvaliabiltyRepository;

  ChangePetrolAvaliablityUsecase({required this.fuelAvaliabiltyRepository});

  Future<Map<String, dynamic>> call(String stationId, String fuelType) async {
    return fuelAvaliabiltyRepository.changePetrolFuelAvaliabilty(
      stationId,
      fuelType,
    );
  }
}

