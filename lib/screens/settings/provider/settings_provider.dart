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

  // Reward controllers
  TextEditingController referralRewardCtrl = TextEditingController();
  TextEditingController firstOrderRewardCtrl = TextEditingController();

  // Delivery & charges controllers
  TextEditingController deliveryWithin1kmCtrl = TextEditingController();
  TextEditingController deliveryPerKm2to5Ctrl = TextEditingController();
  TextEditingController deliveryOver5kmCtrl = TextEditingController();
  TextEditingController handlingChargeCtrl = TextEditingController();

  // Driver earnings controllers
  TextEditingController driverPickupFreeKmCtrl = TextEditingController();
  TextEditingController driverPickupRateCtrl = TextEditingController();
  TextEditingController driverDropRateCtrl = TextEditingController();

  // Payment & withdrawal controllers
  TextEditingController razorpayFeePercentCtrl = TextEditingController();
  TextEditingController minWithdrawalAmountCtrl = TextEditingController();

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
          deliveryWithin1kmCtrl.text = currentSetting?.deliveryChargeWithin1km?.toString() ?? '10';
          deliveryPerKm2to5Ctrl.text = currentSetting?.deliveryChargePerKm2to5?.toString() ?? '9';
          deliveryOver5kmCtrl.text = currentSetting?.deliveryChargeOver5km?.toString() ?? '29';
          handlingChargeCtrl.text = currentSetting?.handlingCharge?.toString() ?? '5';
          driverPickupFreeKmCtrl.text = currentSetting?.driverPickupFreeKm?.toString() ?? '1';
          driverPickupRateCtrl.text = currentSetting?.driverPickupRatePerKm?.toString() ?? '3';
          driverDropRateCtrl.text = currentSetting?.driverDropRatePerKm?.toString() ?? '12';
          razorpayFeePercentCtrl.text = currentSetting?.razorpayFeePercent?.toString() ?? '2';
          minWithdrawalAmountCtrl.text = currentSetting?.minWithdrawalAmount?.toString() ?? '100';
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

      Map<String, dynamic> data = {
        "referralRewardPercent": double.tryParse(referralRewardCtrl.text) ?? 0,
        "firstOrderRewardPercent": double.tryParse(firstOrderRewardCtrl.text) ?? 0,
        "deliveryChargeWithin1km": double.tryParse(deliveryWithin1kmCtrl.text) ?? 10,
        "deliveryChargePerKm2to5": double.tryParse(deliveryPerKm2to5Ctrl.text) ?? 9,
        "deliveryChargeOver5km": double.tryParse(deliveryOver5kmCtrl.text) ?? 29,
        "handlingCharge": double.tryParse(handlingChargeCtrl.text) ?? 5,
        "driverPickupFreeKm": double.tryParse(driverPickupFreeKmCtrl.text) ?? 1,
        "driverPickupRatePerKm": double.tryParse(driverPickupRateCtrl.text) ?? 3,
        "driverDropRatePerKm": double.tryParse(driverDropRateCtrl.text) ?? 12,
        "razorpayFeePercent": double.tryParse(razorpayFeePercentCtrl.text) ?? 2,
        "minWithdrawalAmount": double.tryParse(minWithdrawalAmountCtrl.text) ?? 100,
      };

      final response = await GetConnect(timeout: const Duration(seconds: 60))
          .put('${service.baseUrl}/setting', data);
      
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
