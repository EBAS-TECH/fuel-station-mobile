import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:station_manager/core/exceptions/app_exceptions.dart';
import 'package:station_manager/core/utils/exception_handler.dart';
import 'package:station_manager/core/utils/token_services.dart';

class FuelAvaliablityRemoteDataSource {
  final String baseUrl = "${dotenv.get("BASE_URL")}/availability";
  final TokenService tokenService;

  FuelAvaliablityRemoteDataSource({required this.tokenService});

  Future<Map<String, dynamic>> checkPetrolAvaliabilty(
    String stationId,
    String fuelType,
  ) async {
    try {
      final token = await tokenService.getAuthToken();
      final response = await http.put(
        Uri.parse('$baseUrl/IsAvailable/$stationId'),
        body: jsonEncode({"fuel_type": fuelType}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      print("Petrol $responseData");
      switch (response.statusCode) {
        case 200:
          return responseData;
        case 400:
          throw BadRequestException(message: responseData['error']);
        case 401:
          throw UnAuthorizedException(message: responseData['error']);
        case 404:
          throw NotFoundException(message: responseData['error']);
        case 500:
          throw ServerErrorException(message: responseData['error']);
        default:
          throw FetchDataException(
            message: 'Error occurred while communicating with server',
          );
      }
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> checkDieselAvaliabilty(
    String stationId,
    String fuelType,
  ) async {
    try {
      final token = await tokenService.getAuthToken();
      final response = await http.put(
        Uri.parse('$baseUrl/IsAvailable/$stationId'),
        body: jsonEncode({"station_id": stationId, "fuel_type": fuelType}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      print("Diesel $responseData");
      switch (response.statusCode) {
        case 200:
          return responseData;
        case 400:
          throw BadRequestException(message: responseData['error']);
        case 401:
          throw UnAuthorizedException(message: responseData['error']);
        case 404:
          throw NotFoundException(message: responseData['error']);
        case 500:
          throw ServerErrorException(message: responseData['error']);
        default:
          throw FetchDataException(
            message: 'Error occurred while communicating with server',
          );
      }
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePetrolAvaliablity(
    String stationId,
    String fuelType,
  ) async {
    try {
      final token = await tokenService.getAuthToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({"station_id": stationId, "fuel_type": fuelType}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      print("Change Petrol $responseData");
      
      if (response.statusCode == 200) {
        if (responseData.containsKey('message') && 
            responseData['message'].toLowerCase().contains('success')) {
          return {
            'status': 200,
            'message': responseData['message'],
            'data': {'available': !(responseData['data']?['available'] ?? false)}
          };
        }
        return responseData;
      }

      switch (response.statusCode) {
        case 400:
          throw BadRequestException(message: responseData['error']);
        case 401:
          throw UnAuthorizedException(message: responseData['error']);
        case 404:
          throw NotFoundException(message: responseData['error']);
        case 500:
          throw ServerErrorException(message: responseData['error']);
        default:
          throw FetchDataException(
            message: 'Error occurred while communicating with server',
          );
      }
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> changeDieselAvaliablity(
    String stationId,
    String fuelType,
  ) async {
    try {
      final token = await tokenService.getAuthToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        body: jsonEncode({"station_id": stationId, "fuel_type": fuelType}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      
      if (response.statusCode == 200) {
        if (responseData.containsKey('message') && 
            responseData['message'].toLowerCase().contains('success')) {
          return {
            'status': 200,
            'message': responseData['message'],
            'data': {'available': !(responseData['data']?['available'] ?? false)}
          };
        }
        return responseData;
      }

      switch (response.statusCode) {
        case 400:
          throw BadRequestException(message: responseData['error']);
        case 401:
          throw UnAuthorizedException(message: responseData['error']);
        case 404:
          throw NotFoundException(message: responseData['error']);
        case 500:
          throw ServerErrorException(message: responseData['error']);
        default:
          throw FetchDataException(
            message: 'Error occurred while communicating with server',
          );
      }
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }
}

