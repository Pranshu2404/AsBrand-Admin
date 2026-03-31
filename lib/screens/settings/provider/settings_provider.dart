import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../models/api_response.dart';
import '../../../models/setting.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class SettingsProvider extends ChangeNotifier {
  HttpService service = HttpService();
  Setting? currentSetting;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  TextEditingController referralRewardCtrl = TextEditingController();
  TextEditingController firstOrderRewardCtrl = TextEditingController();

  SettingsProvider() {
    getSettings();
  }

  Future<void> getSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await service.getItems(endpointUrl: 'setting');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true && apiResponse.data != null) {
          currentSetting = Setting.fromJson(apiResponse.data);
          referralRewardCtrl.text = currentSetting?.referralRewardPercent?.toString() ?? '0';
          firstOrderRewardCtrl.text = currentSetting?.firstOrderRewardPercent?.toString() ?? '0';
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Failed to load settings: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      log('Error getting settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings() async {
    try {
      _isSubmitting = true;
      notifyListeners();

      double refPercent = double.tryParse(referralRewardCtrl.text) ?? 0;
      double firstPercent = double.tryParse(firstOrderRewardCtrl.text) ?? 0;

      Map<String, dynamic> data = {
        "referralRewardPercent": refPercent,
        "firstOrderRewardPercent": firstPercent
      };

      // We use PUT /setting as defined in backend. We can use addItem or updateItem, but backend doesn't expect :id for PUT /setting  
      // I'll use GetConnect directly or bypass HTTP Service if needed, but wait: updateItem in HttpService adds itemId at the end.
      // So I will just use `addItem` which calls POST, wait! Backend expects PUT.
      // Let's call PUT directly using GetConnect.
      final response = await service.httpClient.put('${service.baseUrl}/setting', body: data);
      
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Settings Updated Successfully');
          getSettings();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to update settings: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.statusText}');
      }
    } catch (e) {
      log('Error updating settings: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
