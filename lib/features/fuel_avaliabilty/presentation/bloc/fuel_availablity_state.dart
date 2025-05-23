class FuelAvailabilityState {}

class FuelAvailabilityInitial extends FuelAvailabilityState {}

class FuelAvailabilityLoading extends FuelAvailabilityState {}

class FuelAvailabilitySuccess extends FuelAvailabilityState {
  final Map<String, dynamic> response;

  FuelAvailabilitySuccess(this.response);
}

class FuelAvailabilityError extends FuelAvailabilityState {
  final String message;

  FuelAvailabilityError(this.message);
}

