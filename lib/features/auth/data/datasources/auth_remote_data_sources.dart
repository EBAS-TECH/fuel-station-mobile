import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:station_manager/core/exceptions/app_exceptions.dart';
import 'package:station_manager/core/utils/exception_handler.dart';
import 'package:station_manager/core/utils/token_services.dart';

class AuthRemoteDataSources {
  final String baseUrl = "${dotenv.get("BASE_URL")}/auth";
  final TokenService tokenService;

  AuthRemoteDataSources({required this.tokenService});

  Future<Map<String, dynamic>> login(String userName, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: jsonEncode({"username": userName, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      final responseData = jsonDecode(response.body);
      print("AuthRemote $responseData");
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
    } on http.ClientException catch (e) {
      throw FetchDataException(message: e.message);
    } on FormatException catch (_) {
      throw FormatException(message: 'Invalid response format');
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }

  Future<void> logOut() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw FetchDataException(message: 'Logout failed');
      }
    } catch (e) {
      throw ExceptionHandler.handleError(e);
    }
  }
}

