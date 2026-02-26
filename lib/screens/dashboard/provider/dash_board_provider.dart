import 'dart:developer';
import 'package:admin/services/file_handling/file_service.dart';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../services/http_services.dart';
import '../../../models/product.dart';

class DashBoardProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addProductFormKey = GlobalKey<FormState>();

  //?text editing controllers in dashBoard screen
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescCtrl = TextEditingController();
  TextEditingController productQntCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productOffPriceCtrl = TextEditingController();
  
  // New enhanced product fields
  TextEditingController productSkuCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productLengthCtrl = TextEditingController();
  TextEditingController productWidthCtrl = TextEditingController();
  TextEditingController productHeightCtrl = TextEditingController();
  TextEditingController productWarrantyCtrl = TextEditingController();
  TextEditingController productMetaTitleCtrl = TextEditingController();
  TextEditingController productMetaDescCtrl = TextEditingController();
  TextEditingController productTagsCtrl = TextEditingController();
  TextEditingController productLowStockCtrl = TextEditingController();
  
  // New product specifications
  List<Map<String, String>> productSpecs = [];
  
  // Toggle fields
  bool isFeatured = false;
  bool isEmiEligible = true;
  bool isProductActive = true;
  String stockStatus = 'in_stock';

  // Clothing-specific fields
  TextEditingController productMaterialCtrl = TextEditingController();
  TextEditingController productCareCtrl = TextEditingController();
  String? selectedGender;
  String? selectedFit;
  String? selectedPattern;
  String? selectedSleeveLength;
  String? selectedNeckline;
  String? selectedOccasion;
  
  // Clothing dropdown options
  static const List<String> genderOptions = ['Men', 'Women', 'Unisex', 'Boys', 'Girls'];
  static const List<String> fitOptions = ['Regular Fit', 'Slim Fit', 'Relaxed Fit', 'Oversized', 'Skinny Fit'];
  static const List<String> patternOptions = ['Solid', 'Striped', 'Printed', 'Checked', 'Self Design', 'Graphic', 'Floral', 'Polka Dots'];
  static const List<String> sleeveLengthOptions = ['Full Sleeve', 'Half Sleeve', 'Sleeveless', '3/4 Sleeve', 'Roll-up Sleeve'];
  static const List<String> necklineOptions = ['Round Neck', 'V-Neck', 'Collar', 'Mandarin Collar', 'Crew Neck', 'Polo', 'Scoop Neck'];
  static const List<String> occasionOptions = ['Casual', 'Formal', 'Party', 'Sports', 'Ethnic', 'Lounge', 'Workwear'];

  //? dropdown value
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Brand? selectedBrand;

  /// Each entry: { 'variantType': VariantType?, 'availableVariants': List<String>, 'selectedVariants': List<String> }
  List<Map<String, dynamic>> variantRows = [];

  Product? productForUpdate;
  AppFile? selectedMainImage,
      selectedSecondImage,
      selectedThirdImage,
      selectedFourthImage,
      selectedFifthImage;
  XFile? mainImgXFile,
      secondImgXFile,
      thirdImgXFile,
      fourthImgXFile,
      fifthImgXFile;

  List<SubCategory> subCategoriesByCategory = [];
  List<Brand> brandsBySubCategory = [];

  DashBoardProvider(this._dataProvider) {
    productNameCtrl.addListener(updateUI);
    productPriceCtrl.addListener(updateUI);
    productQntCtrl.addListener(updateUI);
  }

  bool get checkProductValidity {
    bool isBasicValid = productNameCtrl.text.isNotEmpty &&
        productPriceCtrl.text.isNotEmpty &&
        productQntCtrl.text.isNotEmpty &&
        selectedCategory != null &&
        selectedSubCategory != null &&
        selectedBrand != null;

    bool isClothingValid = selectedGender != null;

    // If updating, image is already there (or optional). If adding, need main image.
    bool isImageValid = selectedMainImage != null || productForUpdate != null;

    return isBasicValid && isClothingValid && isImageValid;
  }

  //TODO: should complete addProduct
  addProduct() async {
    try {
      if (selectedMainImage == null) {
        SnackBarHelper.showErrorSnackBar('Please Choose An Image!');
        return; // Stop the program execution
      }

      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'sku': productSkuCtrl.text.isEmpty ? null : productSkuCtrl.text,
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'proBrandId': selectedBrand?.sId ?? '',
        'price': productPriceCtrl.text,
        'offerPrice': productOffPriceCtrl.text.isEmpty
            ? productPriceCtrl.text
            : productOffPriceCtrl.text,
        'quantity': productQntCtrl.text,
        'proVariantTypeId': variantRows.isNotEmpty ? (variantRows.first['variantType'] as VariantType?)?.sId : null,
        'proVariantId': variantRows.expand<String>((row) => (row['selectedVariants'] as List<String>?) ?? []).toList(),
        // New enhanced fields
        'weight': productWeightCtrl.text.isEmpty ? 0 : double.tryParse(productWeightCtrl.text) ?? 0,
        'dimensions': {
          'length': double.tryParse(productLengthCtrl.text) ?? 0,
          'width': double.tryParse(productWidthCtrl.text) ?? 0,
          'height': double.tryParse(productHeightCtrl.text) ?? 0,
        },
        'stockStatus': stockStatus,
        'lowStockThreshold': int.tryParse(productLowStockCtrl.text) ?? 10,
        'tags': productTagsCtrl.text.isEmpty 
            ? [] 
            : productTagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        'specifications': productSpecs,
        'warranty': productWarrantyCtrl.text,
        'featured': isFeatured,
        'emiEligible': isEmiEligible,
        'isActive': isProductActive,
        'metaTitle': productMetaTitleCtrl.text,
        'metaDescription': productMetaDescCtrl.text,
        // Clothing-specific fields
        'gender': selectedGender,
        'material': productMaterialCtrl.text,
        'fit': selectedFit,
        'pattern': selectedPattern,
        'sleeveLength': selectedSleeveLength,
        'neckline': selectedNeckline,
        'occasion': selectedOccasion,
        'careInstructions': productCareCtrl.text,
      };

      final FormData form = await createFormDataForMultipleImage(imgXFiles: [
        {'image1': mainImgXFile},
        {'image2': secondImgXFile},
        {'image3': thirdImgXFile},
        {'image4': fourthImgXFile},
        {'image5': fifthImgXFile}
      ], formData: formDataMap);

      if (productForUpdate != null) {
        // This is for update - needs to be handled separately
      }

      final response =
          await service.addItem(endpointUrl: 'products', itemData: form);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllProduct();
          log('Product added');
          clearFields(); // Duplicate line - can be removed
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add product: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  //TODO: should complete updateProduct
  updateProduct() async {
    try {
      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'sku': productSkuCtrl.text.isEmpty ? null : productSkuCtrl.text,
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'proBrandId': selectedBrand?.sId ?? '',
        'price': productPriceCtrl.text,
        'offerPrice': productOffPriceCtrl.text.isEmpty
            ? productPriceCtrl.text
            : productOffPriceCtrl.text,
        'quantity': productQntCtrl.text,
        'proVariantTypeId': variantRows.isNotEmpty ? (variantRows.first['variantType'] as VariantType?)?.sId ?? '' : '',
        'proVariantId': variantRows.expand<String>((row) => (row['selectedVariants'] as List<String>?) ?? []).toList(),
        'weight': productWeightCtrl.text.isEmpty ? 0 : double.tryParse(productWeightCtrl.text) ?? 0,
        'dimensions': {
          'length': double.tryParse(productLengthCtrl.text) ?? 0,
          'width': double.tryParse(productWidthCtrl.text) ?? 0,
          'height': double.tryParse(productHeightCtrl.text) ?? 0,
        },
        'stockStatus': stockStatus,
        'lowStockThreshold': int.tryParse(productLowStockCtrl.text) ?? 10,
        'tags': productTagsCtrl.text.isEmpty 
            ? [] 
            : productTagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        'specifications': productSpecs,
        'warranty': productWarrantyCtrl.text,
        'featured': isFeatured,
        'emiEligible': isEmiEligible,
        'isActive': isProductActive,
        'metaTitle': productMetaTitleCtrl.text,
        'metaDescription': productMetaDescCtrl.text,
        // Clothing-specific fields
        'gender': selectedGender,
        'material': productMaterialCtrl.text,
        'fit': selectedFit,
        'pattern': selectedPattern,
        'sleeveLength': selectedSleeveLength,
        'neckline': selectedNeckline,
        'occasion': selectedOccasion,
        'careInstructions': productCareCtrl.text,
      };

      final FormData form = await createFormDataForMultipleImage(imgXFiles: [
        {'image1': mainImgXFile},
        {'image2': secondImgXFile},
        {'image3': thirdImgXFile},
        {'image4': fourthImgXFile},
        {'image5': fifthImgXFile}
      ], formData: formDataMap);

      if (productForUpdate != null) {
        final response = await service.updateItem(
            endpointUrl: 'products',
            itemData: form,
            itemId: '${productForUpdate?.sId}');

        if (response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if (apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            log('Product updated');
            _dataProvider.getAllProduct();
          } else {
            SnackBarHelper.showErrorSnackBar(
                'Failed to update product: ${apiResponse.message}');
          }
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  //TODO: should complete submitProduct
  submitProduct() {
    if (productForUpdate != null) {
      updateProduct();
    } else {
      addProduct();
    }
  }

  //TODO: should complete deleteProduct
  deleteProduct(Product product) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'products', itemId: product.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Product Deleted Successfully');
          _dataProvider.getAllProduct();
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      return;
    }
  }

  void pickImage({required int imageCardNumber}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (imageCardNumber == 1) {
        selectedMainImage = AppFile(image.path);
        mainImgXFile = image;
      } else if (imageCardNumber == 2) {
        selectedSecondImage = AppFile(image.path);
        secondImgXFile = image;
      } else if (imageCardNumber == 3) {
        selectedThirdImage = AppFile(image.path);
        thirdImgXFile = image;
      } else if (imageCardNumber == 4) {
        selectedFourthImage = AppFile(image.path);
        fourthImgXFile = image;
      } else if (imageCardNumber == 5) {
        selectedFifthImage = AppFile(image.path);
        fifthImgXFile = image;
      }
      notifyListeners();
    }
  }

  Future<FormData> createFormDataForMultipleImage({
    required List<Map<String, XFile?>>? imgXFiles,
    required Map<String, dynamic> formData,
  }) async {
    // Loop over the provided image files and add them to the form data
    if (imgXFiles != null) {
      for (int i = 0; i < imgXFiles.length; i++) {
        XFile? imgXFile = imgXFiles[i]['image' + (i + 1).toString()];
        if (imgXFile != null) {
          // Check if it's running on the web
          if (kIsWeb) {
            String fileName = imgXFile.name;
            Uint8List byteImg = await imgXFile.readAsBytes();
            formData['image' + (i + 1).toString()] =
                MultipartFile(byteImg, filename: fileName);
          } else {
            String filePath = imgXFile.path;
            String fileName = filePath.split('/').last;
            formData['image' + (i + 1).toString()] =
                await MultipartFile(filePath, filename: fileName);
          }
        }
      }
    }

    // Create and return the FormData object
    final FormData form = FormData(formData);
    return form;
  }

  //TODO: should complete filterSubcategory
  filterSubcategory(category) {
    selectedSubCategory = null;
    selectedBrand = null;
    selectedCategory = category;
    subCategoriesByCategory.clear();

    final newList = _dataProvider.subCategories
        .where((subcategory) => subcategory.categoryId?.sId == category.sId)
        .toList();
    subCategoriesByCategory = newList;
    notifyListeners();
  }

  //TODO: should complete filterBrand
  filterBrand(SubCategory subCategory) {
    selectedBrand = null;
    selectedSubCategory = subCategory;
    brandsBySubCategory.clear();

    final newList = _dataProvider.brands
        .where((brand) => brand.subcategoryId?.sId == subCategory.sId)
        .toList();
    brandsBySubCategory = newList;
    notifyListeners();
  }

  /// Add a new empty variant row
  void addVariantRow() {
    variantRows.add({
      'variantType': null,
      'availableVariants': <String>[],
      'selectedVariants': <String>[],
    });
    notifyListeners();
  }

  /// Remove a variant row by index
  void removeVariantRow(int index) {
    if (index >= 0 && index < variantRows.length) {
      variantRows.removeAt(index);
      notifyListeners();
    }
  }

  /// Set the variant type for a specific row, filtering available variants
  void updateVariantTypeForRow(int index, VariantType variantType) {
    if (index >= 0 && index < variantRows.length) {
      variantRows[index]['variantType'] = variantType;
      variantRows[index]['selectedVariants'] = <String>[];

      final filtered = _dataProvider.variants
          .where((v) => v.variantTypeId?.sId == variantType.sId)
          .toList();
      variantRows[index]['availableVariants'] =
          filtered.map((v) => v.name ?? '').toList();
      notifyListeners();
    }
  }

  /// Update selected variants for a specific row
  void updateSelectedVariantsForRow(int index, List<String> selected) {
    if (index >= 0 && index < variantRows.length) {
      variantRows[index]['selectedVariants'] = selected;
      notifyListeners();
    }
  }

  /// Get variant types already chosen in other rows (to exclude from dropdown)
  List<String> getUsedVariantTypeIds({int? excludeIndex}) {
    return variantRows
        .asMap()
        .entries
        .where((e) => e.key != excludeIndex && e.value['variantType'] != null)
        .map((e) => (e.value['variantType'] as VariantType).sId ?? '')
        .toList();
  }

  setDataForUpdateProduct(Product? product) {
    if (product != null) {
      productForUpdate = product;

      productNameCtrl.text = product.name ?? '';
      productDescCtrl.text = product.description ?? '';
      productPriceCtrl.text = product.price.toString();
      productOffPriceCtrl.text = '${product.offerPrice}';
      productQntCtrl.text = '${product.quantity}';
      
      // New enhanced fields
      productSkuCtrl.text = product.sku ?? '';
      productWeightCtrl.text = '${product.weight ?? 0}';
      productLengthCtrl.text = '${product.dimensions?.length ?? 0}';
      productWidthCtrl.text = '${product.dimensions?.width ?? 0}';
      productHeightCtrl.text = '${product.dimensions?.height ?? 0}';
      productWarrantyCtrl.text = product.warranty ?? '';
      productMetaTitleCtrl.text = product.metaTitle ?? '';
      productMetaDescCtrl.text = product.metaDescription ?? '';
      productTagsCtrl.text = product.tags?.join(', ') ?? '';
      productLowStockCtrl.text = '${product.lowStockThreshold ?? 10}';
      
      // Toggle fields
      isFeatured = product.featured ?? false;
      isEmiEligible = product.emiEligible ?? true;
      isProductActive = product.isActive ?? true;
      stockStatus = product.stockStatus ?? 'in_stock';
      
      // Specifications
      productSpecs = product.specifications?.map((s) => {'key': s.key ?? '', 'value': s.value ?? ''}).toList() ?? [];

      // Clothing-specific fields
      productMaterialCtrl.text = product.material ?? '';
      productCareCtrl.text = product.careInstructions ?? '';
      selectedGender = product.gender;
      selectedFit = product.fit;
      selectedPattern = product.pattern;
      selectedSleeveLength = product.sleeveLength;
      selectedNeckline = product.neckline;
      selectedOccasion = product.occasion;

      selectedCategory = _dataProvider.categories.firstWhereOrNull(
          (element) => element.sId == product.proCategoryId?.sId);

      final newListCategory = _dataProvider.subCategories
          .where((subcategory) =>
              subcategory.categoryId?.sId == product.proCategoryId?.sId)
          .toList();
      subCategoriesByCategory = newListCategory;
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == product.proSubCategoryId?.sId);

      final newListBrand = _dataProvider.brands
          .where((brand) =>
              brand.subcategoryId?.sId == product.proSubCategoryId?.sId)
          .toList();
      brandsBySubCategory = newListBrand;
      selectedBrand = _dataProvider.brands.firstWhereOrNull(
          (element) => element.sId == product.proBrandId?.sId);

      // Populate variant rows from existing product data
      variantRows = [];
      final existingVariantType = _dataProvider.variantTypes.firstWhereOrNull(
          (element) => element.sId == product.proVariantTypeId?.sId);
      if (existingVariantType != null) {
        final filteredVariants = _dataProvider.variants
            .where((v) => v.variantTypeId?.sId == existingVariantType.sId)
            .toList();
        variantRows.add({
          'variantType': existingVariantType,
          'availableVariants': filteredVariants.map((v) => v.name ?? '').toList(),
          'selectedVariants': List<String>.from(product.proVariantId ?? []),
        });
      }
    } else {
      clearFields();
    }
  }

  clearFields() {
    productNameCtrl.clear();
    productDescCtrl.clear();
    productPriceCtrl.clear();
    productOffPriceCtrl.clear();
    productQntCtrl.clear();
    
    // Clear new enhanced fields
    productSkuCtrl.clear();
    productWeightCtrl.clear();
    productLengthCtrl.clear();
    productWidthCtrl.clear();
    productHeightCtrl.clear();
    productWarrantyCtrl.clear();
    productMetaTitleCtrl.clear();
    productMetaDescCtrl.clear();
    productTagsCtrl.clear();
    productLowStockCtrl.clear();
    
    // Reset toggle fields
    isFeatured = false;
    isEmiEligible = true;
    isProductActive = true;
    stockStatus = 'in_stock';
    productSpecs = [];

    // Clear clothing fields
    productMaterialCtrl.clear();
    productCareCtrl.clear();
    selectedGender = null;
    selectedFit = null;
    selectedPattern = null;
    selectedSleeveLength = null;
    selectedNeckline = null;
    selectedOccasion = null;

    selectedMainImage = null;
    selectedSecondImage = null;
    selectedThirdImage = null;
    selectedFourthImage = null;
    selectedFifthImage = null;

    mainImgXFile = null;
    secondImgXFile = null;
    thirdImgXFile = null;
    fourthImgXFile = null;
    fifthImgXFile = null;

    selectedCategory = null;
    selectedSubCategory = null;
    selectedBrand = null;
    variantRows = [];

    productForUpdate = null;

    subCategoriesByCategory = [];
    brandsBySubCategory = [];
  }

  updateUI() {
    notifyListeners();
  }
}
