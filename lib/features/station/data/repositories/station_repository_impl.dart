import 'package:station_manager/features/station/data/datasources/station_remote_data_sources.dart';
import 'package:station_manager/features/station/domain/repositories/station_repository.dart';

class StationRepositoryImpl extends StationRepository {
  final StationRemoteDataSources stationRemoteDataSources;

  StationRepositoryImpl({required this.stationRemoteDataSources});
  @override
  Future<Map<String, dynamic>> getStationById(String id) {
    return stationRemoteDataSources.getStationById(id);
  }
}
