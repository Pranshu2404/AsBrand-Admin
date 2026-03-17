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
  final bool gstVerified;
  final String? udyamRegistration;
  final bool udyamVerified;
  final bool isApproved;
  final String? createdAt;
  final String? city;
  final String? state;
  final Map<String, dynamic>? verificationData; // Raw RapidAPI profile data

  SupplierInfo({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.storeName,
    this.gstin,
    this.gstVerified = false,
    this.udyamRegistration,
    this.udyamVerified = false,
    this.isApproved = false,
    this.createdAt,
    this.city,
    this.state,
    this.verificationData,
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
      gstVerified: profile['gstVerified'] ?? false,
      udyamRegistration: profile['udyamRegistration'],
      udyamVerified: profile['udyamVerified'] ?? false,
      isApproved: profile['isApproved'] ?? false,
      createdAt: json['createdAt'],
      city: pickup['city'],
      state: pickup['state'],
      // Parse verificationData if it exists
      verificationData: profile['verificationData'] != null && profile['verificationData'].toString().isNotEmpty
          ? (profile['verificationData'] is Map
              ? profile['verificationData'] as Map<String, dynamic>
              : null)
          : null,
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

  // ── Product Approval ──

  List<ProductInfo> _allProducts = [];
  List<ProductInfo> _filteredProducts = [];
  List<ProductInfo> get products => _filteredProducts;

  int _productTotal = 0;
  int _productPending = 0;
  int _productApproved = 0;
  int get productTotal => _productTotal;
  int get productPending => _productPending;
  int get productApproved => _productApproved;

  Future<void> fetchProducts({bool showSnack = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response response = await service.getItems(endpointUrl: 'supplier/admin/products');
      if (response.isOk && response.body != null) {
        final body = response.body;
        final list = (body['data'] as List?) ?? [];
        _allProducts = list.map((e) => ProductInfo.fromJson(e)).toList();
        _filteredProducts = List.from(_allProducts);

        final stats = body['stats'] ?? {};
        _productTotal = stats['total'] ?? _allProducts.length;
        _productPending = stats['pending'] ?? 0;
        _productApproved = stats['approved'] ?? 0;

        if (showSnack) SnackBarHelper.showSuccessSnackBar('${_allProducts.length} products loaded');
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      log('Error fetching products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveProduct(String productId) async {
    try {
      Response response = await service.updateItem(
        endpointUrl: 'supplier/admin/products/approve',
        itemId: productId,
        itemData: {},
      );
      if (response.isOk) {
        SnackBarHelper.showSuccessSnackBar('Product approved!');
        await fetchProducts();
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Failed to approve');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  Future<void> rejectProduct(String productId) async {
    try {
      Response response = await service.updateItem(
        endpointUrl: 'supplier/admin/products/reject',
        itemId: productId,
        itemData: {},
      );
      if (response.isOk) {
        SnackBarHelper.showSuccessSnackBar('Product rejected');
        await fetchProducts();
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Failed to reject');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
    }
  }

  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lower = keyword.toLowerCase();
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(lower) ||
            (p.supplierStoreName ?? '').toLowerCase().contains(lower);
      }).toList();
    }
    notifyListeners();
  }
}

class ProductInfo {
  final String id;
  final String name;
  final double price;
  final double? offerPrice;
  final int quantity;
  final bool isApproved;
  final String? supplierStoreName;
  final String? supplierName;
  final String? categoryName;
  final String? subCategoryName;
  final String? imageUrl;
  final String? createdAt;

  ProductInfo({
    required this.id,
    required this.name,
    required this.price,
    this.offerPrice,
    required this.quantity,
    this.isApproved = false,
    this.supplierStoreName,
    this.supplierName,
    this.categoryName,
    this.subCategoryName,
    this.imageUrl,
    this.createdAt,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    final supplier = json['supplierId'] as Map<String, dynamic>? ?? {};
    final supplierProfile = supplier['supplierProfile'] as Map<String, dynamic>? ?? {};
    final category = json['proCategoryId'];
    final subCategory = json['proSubCategoryId'];
    final images = json['images'] as List? ?? [];

    return ProductInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed',
      price: (json['price'] ?? 0).toDouble(),
      offerPrice: json['offerPrice'] != null ? (json['offerPrice']).toDouble() : null,
      quantity: json['quantity'] ?? 0,
      isApproved: json['isApproved'] ?? false,
      supplierStoreName: supplierProfile['storeName'],
      supplierName: supplier['name'],
      categoryName: category is Map ? category['name'] : null,
      subCategoryName: subCategory is Map ? subCategory['name'] : null,
      imageUrl: images.isNotEmpty ? images[0]['url'] : null,
      createdAt: json['createdAt'],
    );
  }
}
