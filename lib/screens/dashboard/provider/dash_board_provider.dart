import 'dart:convert';
import 'dart:developer';
import 'package:admin/services/file_handling/file_service.dart';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../models/sub_sub_category.dart';
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

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

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
  SubSubCategory? selectedSubSubCategory;
  Brand? selectedBrand;

  /// Each entry: { 'variantType': VariantType?, 'availableVariants': List<String>, 'selectedVariants': List<String> }
  List<Map<String, dynamic>> variantRows = [];

  /// Each entry: { 'skuId': String, 'attributes': Map<String, String>, 'stock': int, 'price': double, 'imageUrl': String?, 'imageFile': AppFile?, 'isUploading': bool }
  List<Map<String, dynamic>> skus = [];

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
  List<SubSubCategory> subSubCategoriesBySubCategory = [];
  List<Brand> brandsBySubCategory = [];

  // Image upload state tracking
  Map<int, bool> imageUploadingState = {};
  Map<int, String> uploadedImageUrls = {};

  DashBoardProvider(this._dataProvider) {
    productNameCtrl.addListener(updateUI);
    productPriceCtrl.addListener(updateUI);
    productQntCtrl.addListener(updateUI);
  }

  bool get isAnyImageUploading => imageUploadingState.values.any((v) => v);

  bool get checkProductValidity {
    bool isBasicValid = productNameCtrl.text.isNotEmpty &&
        productPriceCtrl.text.isNotEmpty &&
        productQntCtrl.text.isNotEmpty &&
        selectedCategory != null &&
        selectedSubCategory != null &&
        selectedSubSubCategory != null &&
        selectedBrand != null;

    bool isClothingValid = selectedGender != null;

    // Need at least main image (uploaded URL, local file, or existing product image)
    bool isImageValid = uploadedImageUrls.containsKey(1) ||
        selectedMainImage != null ||
        productForUpdate != null;

    // Don't allow submit while images are still uploading
    bool isNotUploading = !isAnyImageUploading;

    return isBasicValid && isClothingValid && isImageValid && isNotUploading;
  }

  //TODO: should complete addProduct
  addProduct() async {
    try {
      if (uploadedImageUrls.isEmpty && selectedMainImage == null) {
        SnackBarHelper.showErrorSnackBar('Please Choose An Image!');
        return;
      }

      // Build the image URLs list from pre-uploaded images
      List<String> imageUrlsList = [];
      for (int i = 1; i <= 5; i++) {
        if (uploadedImageUrls.containsKey(i)) {
          imageUrlsList.add(uploadedImageUrls[i]!);
        }
      }

      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'proSubSubCategoryId': selectedSubSubCategory?.sId ?? '',
        'proBrandId': selectedBrand?.sId ?? '',
        'price': productPriceCtrl.text,
        'offerPrice': productOffPriceCtrl.text.isEmpty
            ? productPriceCtrl.text
            : productOffPriceCtrl.text,
        'quantity': productQntCtrl.text,
        'proVariantTypeId': variantRows.isNotEmpty ? (variantRows.first['variantType'] as VariantType?)?.sId : null,
        'proVariantId': variantRows.expand<String>((row) => (row['selectedVariants'] as List<String>?) ?? []).toList(),
        'proVariants': jsonEncode(variantRows
            .where((row) => row['variantType'] != null)
            .map((row) => <String, dynamic>{
              'variantTypeId': (row['variantType'] as VariantType).sId,
              'variantTypeName': (row['variantType'] as VariantType).name,
              'items': row['selectedVariants'] ?? <String>[],

            }).toList()),
        'skus': jsonEncode(skus.map((sku) => {
          'skuId': sku['skuId'],
          'attributes': sku['attributes'],
          'stock': sku['stock'],
          'price': sku['price'],
          'image': sku['imageUrl'],
        }).toList()),
        'imageUrls': jsonEncode(imageUrlsList),
        'weight': productWeightCtrl.text.isEmpty ? 0 : double.tryParse(productWeightCtrl.text) ?? 0,
        'dimensions': jsonEncode({
          'length': double.tryParse(productLengthCtrl.text) ?? 0,
          'width': double.tryParse(productWidthCtrl.text) ?? 0,
          'height': double.tryParse(productHeightCtrl.text) ?? 0,
        }),
        'stockStatus': stockStatus,
        'lowStockThreshold': int.tryParse(productLowStockCtrl.text) ?? 10,
        'tags': jsonEncode(productTagsCtrl.text.isEmpty 
            ? [] 
            : productTagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()),
        'specifications': jsonEncode(productSpecs),
        'warranty': productWarrantyCtrl.text,
        'featured': isFeatured,
        'emiEligible': isEmiEligible,
        'isActive': isProductActive,
        'metaTitle': productMetaTitleCtrl.text,
        'metaDescription': productMetaDescCtrl.text,
        'gender': selectedGender,
        'material': productMaterialCtrl.text,
        'fit': selectedFit,
        'pattern': selectedPattern,
        'sleeveLength': selectedSleeveLength,
        'neckline': selectedNeckline,
        'occasion': selectedOccasion,
        'careInstructions': productCareCtrl.text,
      };

      // No need to send image files — they're already uploaded
      // Just send the form data as a regular FormData (multer will parse it)
      print('[addProduct] uploadedImageUrls: $uploadedImageUrls');
      print('[addProduct] imageUrlsList: $imageUrlsList');
      print('[addProduct] imageUrls field: ${formDataMap['imageUrls']}');
      final FormData form = FormData(formDataMap);

      final response =
          await service.addItem(endpointUrl: 'products', itemData: form);
      print('[Product] API response: status=${response.statusCode} isOk=${response.isOk}');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllProduct();
          log('Product added');
        } else {
          print('[Product] Add failed: ${apiResponse.message}');
          SnackBarHelper.showErrorSnackBar(
              'Failed to add product: ${apiResponse.message}');
        }
      } else {
        print('[Product] Add API error: ${response.statusCode} ${response.statusText}');
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('[Product] Add exception: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
      print('[Product] addProduct completed, isSubmitting=false');
    }
  }

  //TODO: should complete updateProduct
  updateProduct() async {
    try {
      // Build the image URLs list — include existing product image URLs + newly uploaded ones
      List<String> imageUrlsList = [];
      for (int i = 1; i <= 5; i++) {
        if (uploadedImageUrls.containsKey(i)) {
          // Use newly uploaded URL
          imageUrlsList.add(uploadedImageUrls[i]!);
        } else if (productForUpdate != null) {
          // Keep existing product image if available
          final existing = (productForUpdate!.images ?? [])
              .where((img) => img.image == i)
              .toList();
          if (existing.isNotEmpty && existing.first.url != null) {
            imageUrlsList.add(existing.first.url!);
          }
        }
      }

      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'proSubSubCategoryId': selectedSubSubCategory?.sId ?? '',
        'proBrandId': selectedBrand?.sId ?? '',
        'price': productPriceCtrl.text,
        'offerPrice': productOffPriceCtrl.text.isEmpty
            ? productPriceCtrl.text
            : productOffPriceCtrl.text,
        'quantity': productQntCtrl.text,
        'proVariantTypeId': variantRows.isNotEmpty ? (variantRows.first['variantType'] as VariantType?)?.sId ?? '' : '',
        'proVariantId': variantRows.expand<String>((row) => (row['selectedVariants'] as List<String>?) ?? []).toList(),
        'proVariants': jsonEncode(variantRows
            .where((row) => row['variantType'] != null)
            .map((row) => <String, dynamic>{
              'variantTypeId': (row['variantType'] as VariantType).sId,
              'variantTypeName': (row['variantType'] as VariantType).name,
              'items': row['selectedVariants'] ?? <String>[],
            })
            .toList()),
        'skus': jsonEncode(skus.map((sku) => {
          'skuId': sku['skuId'],
          'attributes': sku['attributes'],
          'stock': sku['stock'],
          'price': sku['price'],
          'image': sku['imageUrl'],
        }).toList()),
        'imageUrls': jsonEncode(imageUrlsList),
        'weight': productWeightCtrl.text.isEmpty ? 0 : double.tryParse(productWeightCtrl.text) ?? 0,
        'dimensions': jsonEncode({
          'length': double.tryParse(productLengthCtrl.text) ?? 0,
          'width': double.tryParse(productWidthCtrl.text) ?? 0,
          'height': double.tryParse(productHeightCtrl.text) ?? 0,
        }),
        'stockStatus': stockStatus,
        'lowStockThreshold': int.tryParse(productLowStockCtrl.text) ?? 10,
        'tags': jsonEncode(productTagsCtrl.text.isEmpty 
            ? [] 
            : productTagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()),
        'specifications': jsonEncode(productSpecs),
        'warranty': productWarrantyCtrl.text,
        'featured': isFeatured,
        'emiEligible': isEmiEligible,
        'isActive': isProductActive,
        'metaTitle': productMetaTitleCtrl.text,
        'metaDescription': productMetaDescCtrl.text,
        'gender': selectedGender,
        'material': productMaterialCtrl.text,
        'fit': selectedFit,
        'pattern': selectedPattern,
        'sleeveLength': selectedSleeveLength,
        'neckline': selectedNeckline,
        'occasion': selectedOccasion,
        'careInstructions': productCareCtrl.text,
      };

      final FormData form = FormData(formDataMap);

      if (productForUpdate != null) {
        print('[Product] Sending update API request...');
        final response = await service.updateItem(
            endpointUrl: 'products',
            itemData: form,
            itemId: '${productForUpdate?.sId}');
        print('[Product] Update API response: status=${response.statusCode} isOk=${response.isOk}');

        if (response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if (apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            print('[Product] Updated successfully');
            _dataProvider.getAllProduct(); // refresh in background
          } else {
            print('[Product] Update failed: ${apiResponse.message}');
            SnackBarHelper.showErrorSnackBar(
                'Failed to update product: ${apiResponse.message}');
          }
        } else {
          print('[Product] Update API error: ${response.statusCode} ${response.statusText}');
          SnackBarHelper.showErrorSnackBar(
              'Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (e) {
      print('[Product] Update exception: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
      print('[Product] updateProduct completed, isSubmitting=false');
    }
  }

  //TODO: should complete submitProduct
  Future<void> submitProduct() async {
    if (productForUpdate != null) {
      await updateProduct();
    } else {
      await addProduct();
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
          print('[Product] Deleted successfully');
          _dataProvider.getAllProduct(); // refresh in background
        }
      } else {
        print('[Product] Delete API error: ${response.statusCode} ${response.statusText}');
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('[Product] Delete exception: $e');
      SnackBarHelper.showErrorSnackBar('Failed to delete: $e');
    }
  }

  void pickImage({required int imageCardNumber}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Set local file for immediate preview while we upload
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

      // Start uploading immediately
      imageUploadingState[imageCardNumber] = true;
      notifyListeners();

      try {
        // Build form data for single image upload
        FormData formData;
        if (kIsWeb) {
          String fileName = image.name;
          Uint8List byteImg = await image.readAsBytes();
          formData = FormData({'image': MultipartFile(byteImg, filename: fileName)});
        } else {
          String filePath = image.path;
          String fileName = filePath.split('/').last;
          formData = FormData({'image': await MultipartFile(filePath, filename: fileName)});
        }

        final url = await service.uploadImage(imageData: formData);
        if (url != null) {
          uploadedImageUrls[imageCardNumber] = url;
          log('Image $imageCardNumber uploaded: $url');
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to upload image $imageCardNumber. Please try again.');
          // Clear the failed image
          _clearSingleImage(imageCardNumber);
        }
      } catch (e) {
        print('Image upload error: $e');
        SnackBarHelper.showErrorSnackBar('Error uploading image: $e');
        _clearSingleImage(imageCardNumber);
      } finally {
        imageUploadingState[imageCardNumber] = false;
        notifyListeners();
      }
    }
  }

  void _clearSingleImage(int cardNumber) {
    switch (cardNumber) {
      case 1:
        selectedMainImage = null;
        mainImgXFile = null;
        break;
      case 2:
        selectedSecondImage = null;
        secondImgXFile = null;
        break;
      case 3:
        selectedThirdImage = null;
        thirdImgXFile = null;
        break;
      case 4:
        selectedFourthImage = null;
        fourthImgXFile = null;
        break;
      case 5:
        selectedFifthImage = null;
        fifthImgXFile = null;
        break;
    }
    uploadedImageUrls.remove(cardNumber);
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
    selectedSubSubCategory = null;
    selectedBrand = null;
    selectedCategory = category;
    subCategoriesByCategory.clear();
    subSubCategoriesBySubCategory.clear();

    final newList = _dataProvider.subCategories
        .where((subcategory) => subcategory.categoryId?.sId == category.sId)
        .toList();
    subCategoriesByCategory = newList;
    notifyListeners();
  }

  //TODO: should complete filterBrand
  filterSubSubCategoryAndBrand(SubCategory subCategory) {
    selectedBrand = null;
    selectedSubSubCategory = null;
    selectedSubCategory = subCategory;
    brandsBySubCategory.clear();
    subSubCategoriesBySubCategory.clear();

    final newSubSubList = _dataProvider.subSubCategories
        .where((ssCategory) => ssCategory.subCategoryId?.sId == subCategory.sId)
        .toList();
    subSubCategoriesBySubCategory = newSubSubList;

    final newBrandList = _dataProvider.brands
        .where((brand) => brand.subcategoryId?.sId == subCategory.sId)
        .toList();
    brandsBySubCategory = newBrandList;
    
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
      generateSkus();
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
      generateSkus();
      notifyListeners();
    }
  }

  /// Update selected variants for a specific row
  void updateSelectedVariantsForRow(int index, List<String> selected) {
    if (index >= 0 && index < variantRows.length) {
      variantRows[index]['selectedVariants'] = selected;
      generateSkus();
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

  void generateSkus() {
    // Collect selected variants
    List<Map<String, dynamic>> validRows = variantRows.where((r) => r['variantType'] != null && (r['selectedVariants'] as List).isNotEmpty).toList();
    if (validRows.isEmpty) {
      if (skus.isNotEmpty) {
        skus = [];
        notifyListeners();
      }
      return;
    }

    // Helper to generate combinations
    List<Map<String, String>> combinations = [{}];
    for (var row in validRows) {
      String typeName = (row['variantType'] as VariantType).name ?? 'Variant';
      List<String> items = row['selectedVariants'] as List<String>;
      
      List<Map<String, String>> newCombinations = [];
      for (var combo in combinations) {
        for (var item in items) {
          final newCombo = Map<String, String>.from(combo);
          newCombo[typeName] = item;
          newCombinations.add(newCombo);
        }
      }
      combinations = newCombinations;
    }

    // Update SKUs list, preserving existing data if attributes match
    List<Map<String, dynamic>> newSkus = [];
    for (var combo in combinations) {
      // Find if we already have this SKU
      bool existingFound = false;
      for (var existingSku in skus) {
        if (mapEquals(existingSku['attributes'] as Map, combo)) {
          newSkus.add(existingSku);
          existingFound = true;
          break;
        }
      }
      if (!existingFound) {
        // Generate a SKU ID
        String combinedValues = combo.values.join('-').toUpperCase().replaceAll(' ', '');
        String baseSku = productSkuCtrl.text.isNotEmpty ? '${productSkuCtrl.text}-' : 'SKU-';
        newSkus.add({
          'skuId': '$baseSku$combinedValues',
          'attributes': combo,
          'stock': 0,
          'price': 0,
          'imageUrl': null,
          'imageFile': null,
          'isUploading': false,
        });
      }
    }

    skus = newSkus;
    notifyListeners();
  }

  void pickSkuImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      skus[index]['imageFile'] = AppFile(image.path);
      skus[index]['isUploading'] = true;
      notifyListeners();

      try {
        FormData formData;
        if (kIsWeb) {
          String fileName = image.name;
          Uint8List byteImg = await image.readAsBytes();
          formData = FormData({'image': MultipartFile(byteImg, filename: fileName)});
        } else {
          String filePath = image.path;
          String fileName = filePath.split('/').last;
          formData = FormData({'image': await MultipartFile(filePath, filename: fileName)});
        }

        final url = await service.uploadImage(imageData: formData);
        if (url != null) {
          skus[index]['imageUrl'] = url;
          log('SKU Image uploaded: $url');
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to upload SKU image. Please try again.');
          skus[index]['imageFile'] = null;
        }
      } catch (e) {
        print('SKU Image upload error: $e');
        SnackBarHelper.showErrorSnackBar('Error uploading SKU image: $e');
        skus[index]['imageFile'] = null;
      } finally {
        skus[index]['isUploading'] = false;
        notifyListeners();
      }
    }
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

      final newSubSubCategoryList = _dataProvider.subSubCategories
          .where((ssCategory) =>
              ssCategory.subCategoryId?.sId == product.proSubCategoryId?.sId)
          .toList();
      subSubCategoriesBySubCategory = newSubSubCategoryList;
      selectedSubSubCategory = _dataProvider.subSubCategories.firstWhereOrNull(
          (element) => element.sId == product.proSubSubCategoryId?.sId);

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
      
      // Load SKUs if available
      skus = [];
      if (product.skus != null && product.skus!.isNotEmpty) {
        skus = product.skus!.map((s) => {
          'skuId': s['skuId'] ?? '',
          'attributes': Map<String, String>.from(s['attributes'] ?? {}),
          'stock': s['stock'] ?? 0,
          'price': s['price'] ?? 0,
          'imageUrl': s['image'],
          'imageFile': null,
          'isUploading': false,
        }).toList();
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
    selectedSubSubCategory = null;
    selectedBrand = null;
    variantRows = [];
    skus = [];

    productForUpdate = null;

    subCategoriesByCategory = [];
    subSubCategoriesBySubCategory = [];
    brandsBySubCategory = [];

    // Clear upload state
    imageUploadingState = {};
    uploadedImageUrls = {};
  }

  updateUI() {
    notifyListeners();
  }
}
