import 'dart:convert';
import 'package:get/get_connect.dart';
import 'package:get/get.dart';
import '../utility/constants.dart';

class HttpService extends GetConnect {
  final String baseUrl = MAIN_URL;

  @override
  void onInit() {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = const Duration(seconds: 60);
    super.onInit();
  }

  GetConnect _getClient() {
    final client = GetConnect();
    client.httpClient.timeout = const Duration(seconds: 60);
    return client;
  }

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      print('[HTTP] GET $baseUrl/$endpointUrl');
      return await _getClient().get('$baseUrl/$endpointUrl');
    } catch (e) {
      print('[HTTP] GET error: $e');
      return Response(body: json.encode({'success': false, 'message': e.toString()}), statusCode: 500);
    }
  }

  Future<Response> addItem({required String endpointUrl, required dynamic itemData}) async {
    try {
      print('[HTTP] POST $baseUrl/$endpointUrl');
      final response = await _getClient().post('$baseUrl/$endpointUrl', itemData);
      print('[HTTP] POST response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('[HTTP] POST error: $e');
      return Response(body: json.encode({'success': false, 'message': e.toString()}), statusCode: 500);
    }
  }

  Future<Response> updateItem({required String endpointUrl, required String itemId, required dynamic itemData}) async {
    try {
      print('[HTTP] PUT $baseUrl/$endpointUrl/$itemId');
      return await _getClient().put('$baseUrl/$endpointUrl/$itemId', itemData);
    } catch (e) {
      print('[HTTP] PUT error: $e');
      return Response(body: json.encode({'success': false, 'message': e.toString()}), statusCode: 500);
    }
  }

  Future<Response> deleteItem({required String endpointUrl, required String itemId}) async {
    try {
      print('[HTTP] DELETE $baseUrl/$endpointUrl/$itemId');
      return await _getClient().delete('$baseUrl/$endpointUrl/$itemId');
    } catch (e) {
      print('[HTTP] DELETE error: $e');
      return Response(body: json.encode({'success': false, 'message': e.toString()}), statusCode: 500);
    }
  }
}
