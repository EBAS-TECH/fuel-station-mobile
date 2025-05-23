import 'package:station_manager/features/fuel_avaliabilty/data/datasources/fuel_avaliablity_remote_data_source.dart';
import 'package:station_manager/features/fuel_avaliabilty/domain/repositories/fuel_avaliabilty_repository.dart';

class FuelAvilabiltyImpl extends FuelAvaliabiltyRepository {
  final FuelAvaliablityRemoteDataSource fuelAvaliablityRemoteDataSource;

  FuelAvilabiltyImpl({required this.fuelAvaliablityRemoteDataSource});
  @override
  Future<Map<String, dynamic>> changeDieselFuelAvaliabilty(
    String stationId,
    String fuelType,
  ) {
    return fuelAvaliablityRemoteDataSource.changeDieselAvaliablity(
      stationId,
      fuelType,
    );
  }

  @override
  Future<Map<String, dynamic>> changePetrolFuelAvaliabilty(
    String stationId,
    String fuelType,
  ) {
    return fuelAvaliablityRemoteDataSource.changePetrolAvaliablity(
      stationId,
      fuelType,
    );
  }

  @override
  Future<Map<String, dynamic>> checkDieselFuelAvaliabilty(
    String stationId,
    String fuelType,
  ) {
    return fuelAvaliablityRemoteDataSource.checkDieselAvaliabilty(
      stationId,
      fuelType,
    );
  }

  @override
  Future<Map<String, dynamic>> checkPetrolFuelAvaliabilty(
    String stationId,
    String fuelType,
  ) {
    return fuelAvaliablityRemoteDataSource.checkPetrolAvaliabilty(
      stationId,
      fuelType,
    );
  }
}

