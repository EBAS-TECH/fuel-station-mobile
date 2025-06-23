class StationState {}

class StationInitial extends StationState {}

class StationLoading extends StationState {}

class StationSuccess extends StationState {
  final Map<String, dynamic> response;

  StationSuccess({required this.response, required String message});
}

class StationFailure extends StationState {
  final String error;

  StationFailure({required this.error});
}

class StationNotFound extends StationState {
  final String message;

  StationNotFound({required this.message});
}

