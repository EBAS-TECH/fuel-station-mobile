import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:station_manager/core/exceptions/app_exceptions.dart';
import 'package:station_manager/core/utils/exception_handler.dart';
import 'package:station_manager/core/utils/token_services.dart';

class StationRemoteDataSources {
  final String baseUrl = "${dotenv.get("BASE_URL")}/station/user";
  final TokenService tokenService;

  StationRemoteDataSources({required this.tokenService});

  Future<Map<String, dynamic>> getStationById(String id) async {
    try {
      final token = await tokenService.getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      print(responseData);
      switch (response.statusCode) {
        case 200:
          tokenService.saveStationId(responseData["data"]["id"]);
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
    } on http.ClientException catch (e) {
      throw FetchDataException(message: e.message);
    } on FormatException catch (_) {
      throw FormatException(message: 'Invalid response format');
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }
}

