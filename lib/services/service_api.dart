import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ServiceApi {

  static const String baseUrl = "http://192.168.1.41:8080/api/services";

  static Future<List<ServiceModel>> getServices(int providerId) async {
    final response =
    await http.get(Uri.parse("$baseUrl/provider/$providerId"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load services");
    }
  }

  static Future<ServiceModel> createService(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create service");
    }
  }
}