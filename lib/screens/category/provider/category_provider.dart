import 'package:admin/services/file_handling/file_service.dart';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import 'dart:developer';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  AppFile? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider);

  //TODO: should complete addCategory
  Future<void> addCategory() async {
    try {
      // 1️⃣ Image validation
      if (selectedImage == null) {
        Get.snackbar(
          'Error',
          'Please choose a category image',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 2️⃣ Form data map
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text.trim(),
        'image': 'no_data', // backend will override
      };

      // 3️⃣ Create multipart form data
      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      // 4️⃣ API call
      final response = await service.addItem(
        endpointUrl: 'categories',
        itemData: form,
      );

      // 5️⃣ Handle response
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllCategory();
          log('Category added: ${apiResponse.data}');
        } else {
          SnackBarHelper.showErrorSnackBar('${apiResponse.message}');
          log('Failed to add category: ${apiResponse.message}');
        }
      } else {
        log('Server error: ${response.statusText}');
        SnackBarHelper.showErrorSnackBar(
            'Server error: ${response.statusText}');
      }
    } catch (e) {
      log('Exception: $e');
      SnackBarHelper.showErrorSnackBar('Exception: $e');
    }
  }

  //TODO: should complete updateCategory
  updateCategory() async {
    try {
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': categoryForUpdate?.image ?? '',
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response = await service.updateItem(
          endpointUrl: 'categories',
          itemData: form,
          itemId: categoryForUpdate?.sId ?? '');

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          log('category updated'); // Changed from 'added' to 'updated'
          _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return;
    }
  }

  //TODO: should complete submitCategory
  submitCategory() {
    if (categoryForUpdate == null) {
      addCategory();
    } else {
      updateCategory();
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = AppFile(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  //TODO: should complete deleteCategory
  deleteCategory(Category category) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'categories', itemId: category.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Category Deleted Successfully');
          _dataProvider.getAllCategory();
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

  //? to create form data for sending image with body
  Future<FormData> createFormData(
      {required XFile? imgXFile,
      required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  //TODO: should complete setDataForUpdateCategory
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}
