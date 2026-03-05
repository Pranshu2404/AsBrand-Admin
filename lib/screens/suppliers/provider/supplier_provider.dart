import 'dart:developer';
import 'package:admin/models/api_response.dart';
import 'package:admin/services/http_services.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplierInfo {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? storeName;
  final String? gstin;
  final bool isApproved;
  final String? createdAt;
  final String? city;
  final String? state;

  SupplierInfo({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.storeName,
    this.gstin,
    this.isApproved = false,
    this.createdAt,
    this.city,
    this.state,
  });

  factory SupplierInfo.fromJson(Map<String, dynamic> json) {
    final profile = json['supplierProfile'] as Map<String, dynamic>? ?? {};
    final pickup = profile['pickupAddress'] as Map<String, dynamic>? ?? {};
    return SupplierInfo(
      id: json['_id'] ?? '',
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      storeName: profile['storeName'],
      gstin: profile['gstin'],
      isApproved: profile['isApproved'] ?? false,
      createdAt: json['createdAt'],
      city: pickup['city'],
      state: pickup['state'],
    );
  }
}

class SupplierAdminProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<SupplierInfo> _allSuppliers = [];
  List<SupplierInfo> _filtered = [];
  List<SupplierInfo> get suppliers => _filtered;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalCount = 0;
  int _pendingCount = 0;
  int _approvedCount = 0;
  int get totalCount => _totalCount;
  int get pendingCount => _pendingCount;
  int get approvedCount => _approvedCount;

  Future<void> fetchSuppliers({bool showSnack = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response response = await service.getItems(endpointUrl: 'supplier/admin/pending');
      if (response.isOk && response.body != null) {
        final body = response.body;
        final list = (body['data'] as List?) ?? [];
        _allSuppliers = list.map((e) => SupplierInfo.fromJson(e)).toList();
        _filtered = List.from(_allSuppliers);

        final stats = body['stats'] ?? {};
        _totalCount = stats['total'] ?? _allSuppliers.length;
        _pendingCount = stats['pending'] ?? 0;
        _approvedCount = stats['approved'] ?? 0;

        if (showSnack) SnackBarHelper.showSuccessSnackBar('${_allSuppliers.length} suppliers loaded');
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      log('Error fetching suppliers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveSupplier(String userId) async {
    try {
      Response response = await service.updateItem(
        endpointUrl: 'supplier/admin/approve',
        itemId: userId,
        itemData: {},
      );
      if (response.isOk) {
        SnackBarHelper.showSuccessSnackBar('Supplier approved!');
        await fetchSuppliers();
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Failed to approve');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  Future<void> rejectSupplier(String userId) async {
    try {
      Response response = await service.updateItem(
        endpointUrl: 'supplier/admin/reject',
        itemId: userId,
        itemData: {},
      );
      if (response.isOk) {
        SnackBarHelper.showSuccessSnackBar('Supplier rejected');
        await fetchSuppliers();
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Failed to reject');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  void filterSuppliers(String keyword) {
    if (keyword.isEmpty) {
      _filtered = List.from(_allSuppliers);
    } else {
      final lower = keyword.toLowerCase();
      _filtered = _allSuppliers.where((s) {
        return (s.name ?? '').toLowerCase().contains(lower) ||
            (s.email ?? '').toLowerCase().contains(lower) ||
            (s.storeName ?? '').toLowerCase().contains(lower) ||
            (s.phone ?? '').contains(lower);
      }).toList();
    }
    notifyListeners();
  }
}
