import 'package:station_manager/features/station/domain/repositories/station_repository.dart';

class GetStationByIdUsecase {
  final StationRepository stationRepository;

  GetStationByIdUsecase({required this.stationRepository});

  Future<Map<String, dynamic>> call(String id) async {
    return stationRepository.getStationById(id);
  }
}
