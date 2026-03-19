import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../modules/authentication/models/auth_error_model.dart';
import '../data/datasources/remote_data_source.dart';
import 'exception.dart';

class NetworkParser {
  static const _className = 'RemoteDataSourceImpl';

  static Future<dynamic> callClientWithCatchException(
      CallClientMethod callClientMethod) async {
    try {
      final response = await callClientMethod();
      final request = response.request;

      debugPrint("========== API REQUEST ==========");
      debugPrint("METHOD: ${request?.method}");
      debugPrint("URL: ${request?.url}");
      debugPrint("HEADERS: ${request?.headers}");

      // Query params
      final queryParams = request?.url.queryParametersAll;
      if (queryParams != null && queryParams.isNotEmpty) {
        // Remove token from printed params for cleaner logs
        final cleanParams = Map<String, dynamic>.from(queryParams);
        if (cleanParams.containsKey('token')) {
          cleanParams['token'] = '***';
        }
        debugPrint("QUERY PARAMS: $cleanParams");
      }

      // Request body / payload (POST, PUT, DELETE, PATCH)
      if (request is http.Request) {
        final reqBody = request.body;
        if (reqBody.isNotEmpty) {
          debugPrint("REQUEST BODY: $reqBody");
        }
      }

      debugPrint("========== API RESPONSE ==========");
      debugPrint("STATUS CODE: ${response.statusCode}");
      // Pretty-print JSON response body
      try {
        final decoded = json.decode(response.body);
        final prettyBody = const JsonEncoder.withIndent('  ').convert(decoded);
        debugPrint("RESPONSE BODY:\n$prettyBody");
      } catch (_) {
        debugPrint("RESPONSE BODY: ${response.body}");
      }
      debugPrint("===================================");

      return _responseParser(response);
    } on SocketException {
      log('SocketException', name: _className);
      throw const NetworkException('No internet connection', 10061);
    } on FormatException {
      log('FormatException', name: _className);
      throw const DataFormatException('Data format exception', 422);
    } on TimeoutException {
      log('TimeoutException', name: _className);
      throw const NetworkException('Request timeout', 408);
    } on http.ClientException {
      ///503 Service Unavailable
      log('http ClientException', name: _className);
      throw const NetworkException('Service unavailable', 503);
    }
  }

  static _responseParser(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 400:
        final errorMsg = parsingDoseNotExist(response.body);
        throw BadRequestException(errorMsg, 400);
      case 401:
        final errorMsg = parsingDoseNotExist(response.body);
        throw UnauthorisedException(errorMsg, 401);
      case 402:
        final errorMsg = parsingDoseNotExist(response.body);
        throw UnauthorisedException(errorMsg, 402);
      case 403:
        final errorMsg = parsingDoseNotExist(response.body);
        throw UnauthorisedException(errorMsg, 403);
      case 404:
        throw const UnauthorisedException('Request not found', 404);
      case 405:
        throw const UnauthorisedException('Method not allowed', 405);
      case 408:

        ///408 Request Timeout
        throw const NetworkException('Request timeout', 408);
      case 415:

        /// 415 Unsupported Media Type
        throw const DataFormatException('Data formate exception');

      case 422:

        ///Unprocessable Entity
        final errorMsg = parsingError(response.body);
        debugPrint("errorMsg");
        debugPrint(errorMsg.toString());
        throw InvalidInputException(Errors.fromMap(errorMsg), 422);
      case 500:

        ///500 Internal Server Error
        throw const InternalServerException('Internal server error', 500);

      default:
        throw FetchDataException(
            'Error occur while communication with Server', response.statusCode);
    }
  }

  static parsingError(String body) {
    final errorsMap = json.decode(body);
    try {
      if (errorsMap['errors'] != null) {
        final errors = errorsMap['errors'] as Map;
        return errors;
        // final firstErrorMsg = errors.values.first;
        // if (firstErrorMsg is List) return firstErrorMsg.first;
        // return firstErrorMsg.toString();
      }
      if (errorsMap['message'] != null) {
        return errorsMap['message'];
      }
    } catch (e) {
      log(e.toString(), name: _className);
    }

    return 'Unknown error';
  }

  static String parsingDoseNotExist(String body) {
    final errorsMap = json.decode(body);
    try {
      if (errorsMap['notification'] != null) {
        return errorsMap['notification'];
      }
      if (errorsMap['message'] != null) {
        return errorsMap['message'];
      }
    } catch (e) {
      log(e.toString(), name: _className);
    }
    return 'Credentials does not match';
  }
}
