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
  final String? fullAddress;
  final String? pincode;
  final Map<String, dynamic>? verificationData;
  final Map<String, dynamic>? bankDetails;

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
    this.fullAddress,
    this.pincode,
    this.verificationData,
    this.bankDetails,
  });

  factory SupplierInfo.fromJson(Map<String, dynamic> json) {
    final profile = json['supplierProfile'] as Map<String, dynamic>? ?? {};
    final pickup = profile['pickupAddress'] as Map<String, dynamic>? ?? {};
    final bank = profile['bankDetails'] as Map<String, dynamic>?;
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
      fullAddress: pickup['address'],
      pincode: pickup['pincode'],
      bankDetails: bank,
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

  Future<void> approveProduct(String productId, {double? price, double? offerPrice, double? supplierPrice, double? supplierOfferPrice}) async {
    try {
      // First, update the product prices using the standard update endpoint (as DashBoardProvider does)
      Map<String, dynamic> updateData = {
        if (price != null) 'price': price.toString(),
        if (offerPrice != null) 'offerPrice': offerPrice.toString(),
        if (supplierPrice != null) 'supplierPrice': supplierPrice.toString(),
        if (supplierOfferPrice != null) 'supplierOfferPrice': supplierOfferPrice.toString(),
      };
      
      // We use POST to products/:id for updates, following DashBoardProvider's pattern
      await service.addItem(
        endpointUrl: 'products/$productId',
        itemData: FormData(updateData),
      );

      // Then, call the specific approve endpoint to change the product status
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
      SnackBarHelper.showErrorSnackBar('An error occurred during approval: $e');
    }
  }

  Future<void> updateProductPrice(String productId, {double? price, double? offerPrice}) async {
    try {
      // Use the standard product update endpoint for price updates of already approved products
      Map<String, dynamic> updateData = {
        if (price != null) 'price': price.toString(),
        if (offerPrice != null) 'offerPrice': offerPrice.toString(),
      };

      Response response = await service.addItem(
        endpointUrl: 'products/$productId',
        itemData: FormData(updateData),
      );

      if (response.isOk) {
        SnackBarHelper.showSuccessSnackBar('Price updated successfully!');
        await fetchProducts();
      } else {
        SnackBarHelper.showErrorSnackBar(response.body?['message'] ?? 'Failed to update price');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('An error occurred updating price: $e');
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
  final String? description;
  final double price;
  final double? offerPrice;
  final double? supplierPrice;
  final double? supplierOfferPrice;
  final int quantity;
  final bool isApproved;
  final String? supplierStoreName;
  final String? supplierName;
  final String? supplierEmail;
  final String? categoryName;
  final String? subCategoryName;
  final String? subSubCategoryName;
  final String? imageUrl;
  final List<String> allImageUrls;
  final String? createdAt;

  // Clothing / product attributes
  final String? gender;
  final String? material;
  final String? fit;
  final String? pattern;
  final String? sleeveLength;
  final String? neckline;
  final String? occasion;
  final String? careInstructions;

  // Variants & SKUs
  final List<Map<String, dynamic>> proVariants;
  final List<Map<String, dynamic>> skus;

  // Tags & specifications
  final List<String> tags;
  final List<Map<String, dynamic>> specifications;

  ProductInfo({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.offerPrice,
    this.supplierPrice,
    this.supplierOfferPrice,
    required this.quantity,
    this.isApproved = false,
    this.supplierStoreName,
    this.supplierName,
    this.supplierEmail,
    this.categoryName,
    this.subCategoryName,
    this.subSubCategoryName,
    this.imageUrl,
    this.allImageUrls = const [],
    this.createdAt,
    this.gender,
    this.material,
    this.fit,
    this.pattern,
    this.sleeveLength,
    this.neckline,
    this.occasion,
    this.careInstructions,
    this.proVariants = const [],
    this.skus = const [],
    this.tags = const [],
    this.specifications = const [],
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    final supplier = json['supplierId'] as Map<String, dynamic>? ?? {};
    final supplierProfile = supplier['supplierProfile'] as Map<String, dynamic>? ?? {};
    final category = json['proCategoryId'];
    final subCategory = json['proSubCategoryId'];
    final subSubCategory = json['proSubSubCategoryId'];
    final images = json['images'] as List? ?? [];

    // Parse all image URLs
    final allUrls = <String>[];
    for (final img in images) {
      if (img is Map && img['url'] != null && img['url'].toString().isNotEmpty) {
        allUrls.add(img['url'].toString());
      }
    }

    // Parse SKU images too
    final rawSkus = json['skus'] as List? ?? [];
    final parsedSkus = <Map<String, dynamic>>[];
    for (final sku in rawSkus) {
      if (sku is Map<String, dynamic>) {
        parsedSkus.add(sku);
        // Collect SKU images into allUrls if no product-level images
        if (allUrls.isEmpty) {
          final skuImages = sku['images'] as List? ?? [];
          for (final url in skuImages) {
            if (url is String && url.isNotEmpty && !allUrls.contains(url)) {
              allUrls.add(url);
            }
          }
        }
      }
    }

    // Parse proVariants
    final rawVariants = json['proVariants'] as List? ?? [];
    final parsedVariants = <Map<String, dynamic>>[];
    for (final v in rawVariants) {
      if (v is Map<String, dynamic>) {
        parsedVariants.add(v);
      }
    }

    // Parse tags
    final rawTags = json['tags'] as List? ?? [];
    final parsedTags = rawTags.map((t) => t.toString()).toList();

    // Parse specifications
    final rawSpecs = json['specifications'] as List? ?? [];
    final parsedSpecs = <Map<String, dynamic>>[];
    for (final s in rawSpecs) {
      if (s is Map<String, dynamic>) {
        parsedSpecs.add(s);
      }
    }

    return ProductInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      offerPrice: json['offerPrice'] != null ? (json['offerPrice']).toDouble() : null,
      supplierPrice: json['supplierPrice'] != null ? (json['supplierPrice']).toDouble() : null,
      supplierOfferPrice: json['supplierOfferPrice'] != null ? (json['supplierOfferPrice']).toDouble() : null,
      quantity: json['quantity'] ?? 0,
      isApproved: json['isApproved'] ?? false,
      supplierStoreName: supplierProfile['storeName'],
      supplierName: supplier['name'],
      supplierEmail: supplier['email'],
      categoryName: category is Map ? category['name'] : null,
      subCategoryName: subCategory is Map ? subCategory['name'] : null,
      subSubCategoryName: subSubCategory is Map ? subSubCategory['name'] : null,
      imageUrl: allUrls.isNotEmpty ? allUrls.first : null,
      allImageUrls: allUrls,
      createdAt: json['createdAt'],
      gender: json['gender'],
      material: json['material'],
      fit: json['fit'],
      pattern: json['pattern'],
      sleeveLength: json['sleeveLength'],
      neckline: json['neckline'],
      occasion: json['occasion'],
      careInstructions: json['careInstructions'],
      proVariants: parsedVariants,
      skus: parsedSkus,
      tags: parsedTags,
      specifications: parsedSpecs,
    );
  }
}
