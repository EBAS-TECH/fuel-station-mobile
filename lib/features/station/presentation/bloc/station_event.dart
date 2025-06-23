class StationEvent {}

class GetStationIdEvent extends StationEvent {
  final String id;

  GetStationIdEvent({required this.id});

  
}
