import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/community_model.dart';
import 'package:day1/services/app_database.dart';

class CommunityService {
  final String baseUrl = 'https://dev.doonut.site';

  Future<Map<String, dynamic>> fetchCalendars() async {
    String? accessTokenJson = await AppDataBase.getToken();

    if (accessTokenJson == null) {
      throw Exception('No access token found');
    }

    Map<String, dynamic> accessTokenMap = json.decode(accessTokenJson);
    String accessToken = accessTokenMap['accessToken'];

    if (accessToken == null) {
      throw Exception('Access token is null');
    }

    try {
      final uri = Uri.parse('$baseUrl/calendars?size=10');

      print('Request URI: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final decodedResponse = utf8.decode(response.bodyBytes);

      print('Request Headers: ${response.request!.headers}');
      print('Response status: ${response.statusCode}');
      print('Response body: $decodedResponse');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(decodedResponse);
        List<dynamic> communityJsonList = jsonResponse['values'];
        List<Community> communities = communityJsonList.map((json) => Community.fromJson(json)).toList();
        bool hasNext = jsonResponse['hasNext'];
        return {
          'communities': communities,
          'hasNext': hasNext,
        };
      } else if (response.statusCode == 400) {
        final errorResponse = json.decode(decodedResponse);
        final errorCode = errorResponse['errorCode'];
        if (errorCode == 'COMMUNITY_NOT_ACCESSIBLE') {
          throw Exception('The community calendar is locked due to insufficient records.');
        } else {
          throw Exception('Failed to load community with status: ${response.statusCode}');
        }
      } else {
        throw Exception('Failed to load community with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to load calendars: $e');
    }
  }
}