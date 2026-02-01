import 'dart:developer';
import 'package:admin/models/api_response.dart';
import 'package:admin/models/emi_plan.dart';
import 'package:admin/services/http_services.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmiPlanProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<EmiPlan> _allEmiPlans = [];
  List<EmiPlan> _filteredEmiPlans = [];
  List<EmiPlan> get emiPlans => _filteredEmiPlans;

  final addEmiPlanFormKey = GlobalKey<FormState>();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController tenureCtrl = TextEditingController();
  TextEditingController interestRateCtrl = TextEditingController();
  TextEditingController processingFeeCtrl = TextEditingController();
  TextEditingController minOrderAmountCtrl = TextEditingController();
  TextEditingController maxOrderAmountCtrl = TextEditingController();
  bool isActive = true;

  EmiPlan? emiPlanForUpdate;

  // Get all EMI plans
  Future<List<EmiPlan>> getAllEmiPlans({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'emi/plans');
      if (response.isOk) {
        ApiResponse<List<EmiPlan>> apiResponse = ApiResponse<List<EmiPlan>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => EmiPlan.fromJson(item)).toList(),
        );
        _allEmiPlans = apiResponse.data ?? [];
        _filteredEmiPlans = List.from(_allEmiPlans);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      log('Error fetching EMI plans: $e');
    }
    return _filteredEmiPlans;
  }

  // Filter EMI plans
  void filterEmiPlans(String keyword) {
    if (keyword.isEmpty) {
      _filteredEmiPlans = List.from(_allEmiPlans);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredEmiPlans = _allEmiPlans.where((plan) {
        return (plan.name ?? '').toLowerCase().contains(lowerKeyword) ||
            '${plan.tenure}'.contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  // Add EMI plan
  Future<void> addEmiPlan() async {
    try {
      final Map<String, dynamic> planData = {
        'name': nameCtrl.text.trim(),
        'tenure': int.tryParse(tenureCtrl.text) ?? 3,
        'interestRate': double.tryParse(interestRateCtrl.text) ?? 0,
        'processingFee': double.tryParse(processingFeeCtrl.text) ?? 0,
        'minOrderAmount': double.tryParse(minOrderAmountCtrl.text) ?? 0,
        'maxOrderAmount': maxOrderAmountCtrl.text.isNotEmpty 
            ? double.tryParse(maxOrderAmountCtrl.text) 
            : null,
        'isActive': isActive,
      };

      final response = await service.addItem(
        endpointUrl: 'emi/plans',
        itemData: planData,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('EMI Plan created successfully');
          getAllEmiPlans();
          log('EMI plan added');
        } else {
          SnackBarHelper.showErrorSnackBar('Failed: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
      }
    } catch (e) {
      log('Error adding EMI plan: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }

  // Update EMI plan
  Future<void> updateEmiPlan() async {
    if (emiPlanForUpdate == null) return;

    try {
      final Map<String, dynamic> planData = {
        'name': nameCtrl.text.trim(),
        'tenure': int.tryParse(tenureCtrl.text) ?? 3,
        'interestRate': double.tryParse(interestRateCtrl.text) ?? 0,
        'processingFee': double.tryParse(processingFeeCtrl.text) ?? 0,
        'minOrderAmount': double.tryParse(minOrderAmountCtrl.text) ?? 0,
        'maxOrderAmount': maxOrderAmountCtrl.text.isNotEmpty 
            ? double.tryParse(maxOrderAmountCtrl.text) 
            : null,
        'isActive': isActive,
      };

      final response = await service.updateItem(
        endpointUrl: 'emi/plans',
        itemId: emiPlanForUpdate!.sId ?? '',
        itemData: planData,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('EMI Plan updated successfully');
          getAllEmiPlans();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
      }
    } catch (e) {
      log('Error updating EMI plan: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }

  // Submit (add or update)
  void submitEmiPlan() {
    if (emiPlanForUpdate != null) {
      updateEmiPlan();
    } else {
      addEmiPlan();
    }
  }

  // Delete EMI plan
  Future<void> deleteEmiPlan(EmiPlan plan) async {
    try {
      Response response = await service.deleteItem(
        endpointUrl: 'emi/plans',
        itemId: plan.sId ?? '',
      );
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('EMI Plan deleted successfully');
          getAllEmiPlans();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.statusText}');
      }
    } catch (e) {
      log('Error deleting EMI plan: $e');
    }
  }

  // Set data for update
  void setDataForUpdateEmiPlan(EmiPlan? plan) {
    if (plan != null) {
      emiPlanForUpdate = plan;
      nameCtrl.text = plan.name ?? '';
      tenureCtrl.text = '${plan.tenure ?? 3}';
      interestRateCtrl.text = '${plan.interestRate ?? 0}';
      processingFeeCtrl.text = '${plan.processingFee ?? 0}';
      minOrderAmountCtrl.text = '${plan.minOrderAmount ?? 0}';
      maxOrderAmountCtrl.text = plan.maxOrderAmount != null 
          ? '${plan.maxOrderAmount}' 
          : '';
      isActive = plan.isActive ?? true;
    } else {
      clearFields();
    }
    notifyListeners();
  }

  // Toggle active status
  void toggleActiveStatus(bool value) {
    isActive = value;
    notifyListeners();
  }

  // Clear fields
  void clearFields() {
    nameCtrl.clear();
    tenureCtrl.clear();
    interestRateCtrl.clear();
    processingFeeCtrl.clear();
    minOrderAmountCtrl.clear();
    maxOrderAmountCtrl.clear();
    isActive = true;
    emiPlanForUpdate = null;
    notifyListeners();
  }
}
