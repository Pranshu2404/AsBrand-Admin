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

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  AppFile? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider);

  //TODO: should complete addCategory
  Future<void> addCategory() async {
    try {
      _isSubmitting = true;
      notifyListeners();
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
          print('[Category] Added successfully');
          _dataProvider.getAllCategory(); // refresh in background
        } else {
          SnackBarHelper.showErrorSnackBar('${apiResponse.message}');
          print('[Category] Add failed: ${apiResponse.message}');
        }
      } else {
        print('[Category] Add API error: ${response.statusCode} ${response.statusText}');
        SnackBarHelper.showErrorSnackBar(
            'Server error: ${response.statusText}');
      }
    } catch (e) {
      print('[Category] Add exception: $e');
      SnackBarHelper.showErrorSnackBar('Exception: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  //TODO: should complete updateCategory
  updateCategory() async {
    try {
      _isSubmitting = true;
      notifyListeners();
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
          print('[Category] Updated successfully');
          _dataProvider.getAllCategory(); // refresh in background
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('[Category] Update exception: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  //TODO: should complete submitCategory
  Future<void> submitCategory() async {
    if (categoryForUpdate == null) {
      await addCategory();
    } else {
      await updateCategory();
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
          print('[Category] Deleted successfully');
          _dataProvider.getAllCategory(); // refresh in background
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('[Category] Delete exception: $e');
      SnackBarHelper.showErrorSnackBar('Failed to delete: $e');
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
