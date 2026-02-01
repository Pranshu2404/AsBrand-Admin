import 'dart:developer';
import 'package:admin/models/api_response.dart';
import 'package:admin/models/user_kyc.dart';
import 'package:admin/services/http_services.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KycProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<UserKyc> _pendingKyc = [];
  List<UserKyc> get pendingKyc => _pendingKyc;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Get all pending KYC applications
  Future<void> getPendingKyc({bool showSnack = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response response = await service.getItems(endpointUrl: 'kyc/pending');
      if (response.isOk) {
        ApiResponse<List<UserKyc>> apiResponse = ApiResponse<List<UserKyc>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => UserKyc.fromJson(item)).toList(),
        );
        _pendingKyc = apiResponse.data ?? [];
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      log('Error fetching pending KYC: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Approve KYC
  Future<void> approveKyc(String kycId, double creditLimit) async {
    try {
      final response = await service.updateItem(
        endpointUrl: 'kyc/verify',
        itemId: kycId,
        itemData: {
          'status': 'verified',
          'creditLimit': creditLimit,
        },
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('KYC Approved Successfully!');
          getPendingKyc();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
      }
    } catch (e) {
      log('Error approving KYC: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }

  // Reject KYC
  Future<void> rejectKyc(String kycId, String reason) async {
    try {
      final response = await service.updateItem(
        endpointUrl: 'kyc/verify',
        itemId: kycId,
        itemData: {
          'status': 'rejected',
          'rejectionReason': reason,
        },
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('KYC Rejected');
          getPendingKyc();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
      }
    } catch (e) {
      log('Error rejecting KYC: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }

  // Get statistics
  int get totalPending => _pendingKyc.length;
}
