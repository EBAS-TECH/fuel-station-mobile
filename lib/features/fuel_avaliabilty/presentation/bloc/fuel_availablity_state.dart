class FuelAvailabilityState {}

class FuelAvailabilityInitial extends FuelAvailabilityState {}

class FuelAvailabilityLoading extends FuelAvailabilityState {}

class PetrolAvailabilitySuccess extends FuelAvailabilityState {
  final Map<String, dynamic> response;

  PetrolAvailabilitySuccess(this.response);
}
class DiselAvailabilitySuccess extends FuelAvailabilityState {
  final Map<String, dynamic> response;

  DiselAvailabilitySuccess(this.response);
}

class FuelAvailabilityError extends FuelAvailabilityState {
  final String message;

  FuelAvailabilityError(this.message);
}

