import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:station_manager/core/exceptions/app_exceptions.dart';
import 'package:station_manager/core/utils/exception_handler.dart';
import 'package:station_manager/core/utils/token_services.dart';

class UserRemoteDataSource {
  final String baseUrl = "${dotenv.get("BASE_URL")}/user";
  final TokenService tokenService;

  UserRemoteDataSource({required this.tokenService});

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final token = await tokenService.getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } on SocketException {
      throw SocketException(message: 'No internet connection');
    } on http.ClientException {
      throw SocketException(message: 'Failed to connect to server');
    } on TimeoutException {
      throw TimeoutException(message: 'Connection timeout');
    } catch (e) {
      final exception = ExceptionHandler.handleError(e);
      throw exception;
    }
  }

  dynamic _handleResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData;
        case 400:
          throw BadRequestException(
            message: responseData['error'] ?? 'Invalid user data',
          );
        case 401:
        case 403:
          throw UnAuthorizedException(
            message:
                responseData['message'] ?? 'Unauthorized access to user data',
          );
        case 404:
          throw NotFoundException(
            message: responseData['message'] ?? 'User not found',
          );
        case 409:
          throw ConflictException(
            message: responseData['message'] ?? 'Username already exists',
          );
        case 422:
          throw InvalidInputException(
            message: responseData['message'] ?? 'Invalid input format',
          );
        case 500:
          throw ServerErrorException(
            message: responseData['message'] ?? 'Failed to process user data',
          );
        default:
          throw FetchDataException(
            message:
                responseData['message'] ??
                'Error occurred while processing user request',
          );
      }
    } on FormatException {
      throw FormatException(message: 'Invalid server response format');
    }
  }
}

