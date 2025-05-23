import 'package:station_manager/features/fuel_avaliabilty/domain/repositories/fuel_avaliabilty_repository.dart';

class ChangeDieselAvaliablityUsecase {
  final FuelAvaliabiltyRepository fuelAvaliabiltyRepository;

  ChangeDieselAvaliablityUsecase({required this.fuelAvaliabiltyRepository});

  Future<Map<String, dynamic>> call(String stationId, String fuelType) async {
    return fuelAvaliabiltyRepository.changeDieselFuelAvaliabilty(
      stationId,
      fuelType,
    );
  }
}

