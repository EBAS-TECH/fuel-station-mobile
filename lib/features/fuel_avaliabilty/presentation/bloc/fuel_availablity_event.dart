class FuelAvailabilityEvent {}

class CheckPetrolAvailabilityEvent extends FuelAvailabilityEvent {
  final String stationId;
  final String fuelType;

  CheckPetrolAvailabilityEvent({
    required this.stationId,
    required this.fuelType,
  });
}

class CheckDieselAvailabilityEvent extends FuelAvailabilityEvent {
  final String stationId;
  final String fuelType;

  CheckDieselAvailabilityEvent({
    required this.stationId,
    required this.fuelType,
  });
}

class ChangePetrolAvailabilityEvent extends FuelAvailabilityEvent {
  final String stationId;
  final String fuelType;

  ChangePetrolAvailabilityEvent({
    required this.stationId,
    required this.fuelType,
  });
}

class ChangeDieselAvailabilityEvent extends FuelAvailabilityEvent {
  final String stationId;
  final String fuelType;

  ChangeDieselAvailabilityEvent({
    required this.stationId,
    required this.fuelType,
  });
}

