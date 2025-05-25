abstract class FuelAvailabilityState {
  final bool? petrolAvailable;
  final bool? dieselAvailable;

  const FuelAvailabilityState({
    this.petrolAvailable,
    this.dieselAvailable,
  });
}

class FuelAvailabilityInitial extends FuelAvailabilityState {
  const FuelAvailabilityInitial() : super();
}

class FuelAvailabilityLoading extends FuelAvailabilityState {
  final bool isPetrolLoading;
  final bool isDieselLoading;

  const FuelAvailabilityLoading({
    this.isPetrolLoading = false,
    this.isDieselLoading = false,
  }) : super();
}

class FuelAvailabilityUpdated extends FuelAvailabilityState {
  const FuelAvailabilityUpdated({
    required bool petrolAvailable,
    required bool dieselAvailable,
  }) : super(
          petrolAvailable: petrolAvailable,
          dieselAvailable: dieselAvailable,
        );
}

class FuelAvailabilityError extends FuelAvailabilityState {
  final String message;
  final bool? isPetrolError;

  const FuelAvailabilityError(
    this.message, {
    this.isPetrolError,
    bool? petrolAvailable,
    bool? dieselAvailable,
  }) : super(
          petrolAvailable: petrolAvailable,
          dieselAvailable: dieselAvailable,
        );
}

