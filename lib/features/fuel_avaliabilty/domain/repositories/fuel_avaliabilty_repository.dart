abstract class FuelAvaliabiltyRepository {
  Future<Map<String, dynamic>> checkPetrolFuelAvaliabilty(
    String stationId,
    String fuelType,
  );
  Future<Map<String, dynamic>> checkDieselFuelAvaliabilty(
    String stationId,
    String fuelType,
  );
  Future<Map<String, dynamic>> changePetrolFuelAvaliabilty(
    String stationId,
    String fuelType,
  );
  Future<Map<String, dynamic>> changeDieselFuelAvaliabilty(
    String stationId,
    String fuelType,
  );
}

