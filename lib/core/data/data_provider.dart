import '../../models/api_response.dart';
import '../../models/coupon.dart';
import '../../models/my_notification.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/variant_type.dart';
import '../../services/http_services.dart';
import '../../utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../../models/category.dart';
import '../../models/brand.dart';
import '../../models/sub_category.dart';
import '../../models/variant.dart';

class DataProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];

  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  List<Brand> get brands => _filteredBrands;

  List<VariantType> _allVariantTypes = [];
  List<VariantType> _filteredVariantTypes = [];
  List<VariantType> get variantTypes => _filteredVariantTypes;

  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];
  List<Variant> get variants => _filteredVariants;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> get products => _filteredProducts;

  List<Coupon> _allCoupons = [];
  List<Coupon> _filteredCoupons = [];
  List<Coupon> get coupons => _filteredCoupons;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];
  List<Poster> get posters => _filteredPosters;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

  List<MyNotification> _allNotifications = [];
  List<MyNotification> _filteredNotifications = [];
  List<MyNotification> get notifications => _filteredNotifications;

  DataProvider() {
    getAllProduct();
    getAllCategory();
    getAllSubCategory();
    getAllBrands();
    getAllVariantType();
    getAllVariant();
    getAllPosters();
    getAllCoupons();
    getAllOrders();
  }

  //TODO: should complete getAllCategory
  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'categories');
      if (response.isOk) {
        ApiResponse<List<Category>> apiResponse =
            ApiResponse<List<Category>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Category.fromJson(item)).toList(),
        ); // ApiResponse.fromJson
        _allCategories = apiResponse.data ?? [];
        _filteredCategories =
            List.from(_allCategories); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredCategories;
  }

  //TODO: should complete filterCategories
  void filterCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllSubCategory
  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'subCategories');
      if (response.isOk) {
        ApiResponse<List<SubCategory>> apiResponse =
            ApiResponse<List<SubCategory>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => SubCategory.fromJson(item)).toList(),
        ); // ApiResponse.fromJson
        _allSubCategories = apiResponse.data ?? [];
        _filteredSubCategories = List.from(
            _allSubCategories); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredSubCategories;
  }

  //TODO: should complete filterSubCategories
  void filterSubCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredSubCategories = _allSubCategories.where((subcategory) {
        return (subcategory.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllBrands
  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'brands');
      if (response.isOk) {
        ApiResponse<List<Brand>> apiResponse =
            ApiResponse<List<Brand>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => Brand.fromJson(item)).toList(),
        ); // ApiResponse.fromJson
        _allBrands = apiResponse.data ?? [];
        _filteredBrands =
            List.from(_allBrands); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      return [];
    }
    return _filteredBrands;
  }

  //TODO: should complete filterBrands
  void filterBrands(String keyword) {
    if (keyword.isEmpty) {
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredBrands = _allBrands.where((brand) {
        return (brand.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllVariantType
  Future<List<VariantType>> getAllVariantType({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'variantTypes');
      if (response.isOk) {
        ApiResponse<List<VariantType>> apiResponse =
            ApiResponse<List<VariantType>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => VariantType.fromJson(item)).toList(),
        );
        _allVariantTypes = apiResponse.data ?? [];
        _filteredVariantTypes = List.from(_allVariantTypes);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
    }
    return _filteredVariantTypes;
  }

  //TODO: should complete filterVariantTypes
  void filterVariantTypes(String keyword) {
    if (keyword.isEmpty) {
      _filteredVariantTypes = List.from(_allVariantTypes);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredVariantTypes = _allVariantTypes.where((variantType) {
        return (variantType.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllVariant
  Future<List<Variant>> getAllVariant({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'variants');
      if (response.isOk) {
        ApiResponse<List<Variant>> apiResponse =
            ApiResponse<List<Variant>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Variant.fromJson(item)).toList(),
        ); // ApiResponse.fromJson
        _allVariants = apiResponse.data ?? [];
        _filteredVariants =
            List.from(_allVariants); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredVariants;
  }

  //TODO: should complete filterVariants
  void filterVariants(String keyword) {
    if (keyword.isEmpty) {
      _filteredVariants = List.from(_allVariants);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredVariants = _allVariants.where((variant) {
        return (variant.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllProduct
  Future<List<Product>> getAllProduct({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'products');
      if (response.isOk) {
        ApiResponse<List<Product>> apiResponse =
            ApiResponse<List<Product>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Product.fromJson(item)).toList(),
        ); // ApiResponse.fromJson
        _allProducts = apiResponse.data ?? [];
        _filteredProducts =
            List.from(_allProducts); // Initialize filtered list with all data
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredProducts;
  }

  //TODO: should complete filterProducts
  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowerKeyword = keyword.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final productNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowerKeyword);
        final categoryNameContainsKeyword =
            product.proCategoryId?.name?.toLowerCase().contains(lowerKeyword) ??
                false;
        final subCategoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;

        // You can add more conditions here if there are more fields to match against
        return productNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword;
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllCoupons
  Future<List<Coupon>> getAllCoupons({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'couponCodes');
      if (response.isOk) {
        ApiResponse<List<Coupon>> apiResponse =
            ApiResponse<List<Coupon>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Coupon.fromJson(item)).toList(),
        );
        _allCoupons = apiResponse.data ?? [];
        _filteredCoupons = List.from(_allCoupons);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      } else {
        if (showSnack)
          SnackBarHelper.showErrorSnackBar('Failed to fetch coupons');
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      return [];
    }
    return _filteredCoupons;
  }

  //TODO: should complete filterCoupons
  void filterCoupons(String keyword) {
    if (keyword.isEmpty) {
      _filteredCoupons = List.from(_allCoupons);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredCoupons = _allCoupons.where((coupon) {
        return (coupon.couponCode ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllPosters
  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'posters');
      if (response.isOk) {
        ApiResponse<List<Poster>> apiResponse =
            ApiResponse<List<Poster>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Poster.fromJson(item)).toList(),
        ); // ApiResponse.fromJson
        _allPosters = apiResponse.data ?? [];
        _filteredPosters = List.from(_allPosters);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
    return _filteredPosters;
  }

  //TODO: should complete filterPosters
  void filterPosters(String keyword) {
    if (keyword.isEmpty) {
      _filteredPosters = List.from(_allPosters);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredPosters = _allPosters.where((poster) {
        return (poster.posterName ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete getAllNotifications

  //TODO: should complete filterNotifications

  //TODO: should complete getAllOrders
  Future<List<Order>> getAllOrders({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'orders');
      if (response.isOk) {
        ApiResponse<List<Order>> apiResponse =
            ApiResponse<List<Order>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Order.fromJson(item)).toList(),
        );
        _allOrders = apiResponse.data ?? [];
        _filteredOrders = List.from(_allOrders);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
    }
    return _filteredOrders;
  }

  //TODO: should complete filterOrders
  void filterOrders(String keyword) {
    if (keyword.isEmpty || keyword.toLowerCase() == 'all order') {
      _filteredOrders = List.from(_allOrders);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredOrders = _allOrders.where((order) {
        return (order.orderStatus ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  //TODO: should complete filterProductsByQuantity
  void filterProductsByQuantity(String productQntType) {
    if (productQntType == 'All Product') {
      _filteredProducts = List.from(_allProducts);
    } else if (productQntType == 'Out of Stock') {
      _filteredProducts = _allProducts.where((product) {
        // Filter products with quantity equal to 0 (out of stock)
        return product.quantity != null && product.quantity == 0;
      }).toList();
    } else if (productQntType == 'Limited Stock') {
      _filteredProducts = _allProducts.where((product) {
        // Filter products with quantity equal to 1 (limited stock)
        return product.quantity != null && product.quantity == 1;
      }).toList();
    } else if (productQntType == 'Other Stock') {
      _filteredProducts = _allProducts.where((product) {
        // Filter products with quantity not equal to 0 or 1 (other stock)
        return product.quantity != null &&
            product.quantity != 0 &&
            product.quantity != 1;
      }).toList();
    } else {
      _filteredProducts = List.from(_allProducts);
    }
    notifyListeners();
  }

  //TODO: should complete calculateProductWithQuantity
  int calculateProductWithQuantity({int? quantity}) {
    int totalProducts = 0;
    // If targetQuantity is null it returns total product count
    if (quantity == null) {
      totalProducts = _allProducts.length;
    } else {
      for (Product product in _allProducts) {
        if (product.quantity != null && product.quantity == quantity) {
          totalProducts +=
              1; // Increment the count if quantity matches the target
        }
      }
    }
    return totalProducts;
  }
}
