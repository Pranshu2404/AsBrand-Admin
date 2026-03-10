import 'dart:developer';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/file_handling/file_service.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../models/sub_sub_category.dart';
import '../../../services/http_services.dart';

class SubSubCategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addSubSubCategoryFormKey = GlobalKey<FormState>();
  TextEditingController subSubCategoryNameCtrl = TextEditingController();
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  SubSubCategory? subSubCategoryForUpdate;

  SubSubCategoryProvider(this._dataProvider);

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  AppFile? selectedImage;
  String? uploadedImageUrl;
  bool isImageUploading = false;

  addSubSubCategory() async {
    try {
      _isSubmitting = true;
      notifyListeners();
      Map<String, dynamic> subSubCategory = {
        'name': subSubCategoryNameCtrl.text,
        'categoryId': selectedCategory?.sId,
        'subCategoryId': selectedSubCategory?.sId,
        'image': uploadedImageUrl ?? 'no_url'
      };

      final response = await service.addItem(
          endpointUrl: 'subSubCategories', itemData: subSubCategory);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllSubSubCategory(); // refresh in background
          print('[SubSubCategory] Added successfully');
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add Sub SubCategory: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  updateSubSubCategory() async {
    try {
      _isSubmitting = true;
      notifyListeners();
      if (subSubCategoryForUpdate != null) {
        Map<String, dynamic> subSubCategory = {
          'name': subSubCategoryNameCtrl.text,
          'categoryId': selectedCategory?.sId,
          'subCategoryId': selectedSubCategory?.sId,
          'image': uploadedImageUrl ?? subSubCategoryForUpdate?.image ?? 'no_url'
        };

        final response = await service.updateItem(
            endpointUrl: 'subSubCategories',
            itemData: subSubCategory,
            itemId: subSubCategoryForUpdate?.sId ?? '');

        if (response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if (apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            print('[SubSubCategory] Updated successfully');
            _dataProvider.getAllSubSubCategory(); // refresh in background
          } else {
            SnackBarHelper.showErrorSnackBar(
                'Failed to update Sub SubCategory: ${apiResponse.message}');
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
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> submitSubSubCategory() async {
    if (subSubCategoryForUpdate == null) {
      await addSubSubCategory();
    } else {
      await updateSubSubCategory();
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      isImageUploading = true;
      notifyListeners();
      try {
        XFile finalImage = image;

        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: 'Crop Logo',
                  initAspectRatio: CropAspectRatioPreset.square,
                  lockAspectRatio: true),
              IOSUiSettings(title: 'Crop Logo', aspectRatioLockEnabled: true),
            ],
          );

          if (croppedFile != null) {
            final dir = await getTemporaryDirectory();
            final targetPath =
                '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

            final compressedFile =
                await FlutterImageCompress.compressAndGetFile(
              croppedFile.path,
              targetPath,
              quality: 70,
              minWidth: 500,
              minHeight: 500,
            );

            if (compressedFile != null) {
              finalImage = compressedFile;
            } else {
              finalImage = XFile(croppedFile.path);
            }
          } else {
            isImageUploading = false;
            notifyListeners();
            return;
          }
        }

        selectedImage = AppFile(finalImage.path);
        notifyListeners();

        FormData formData;
        if (kIsWeb) {
          String fileName = finalImage.name;
          Uint8List byteImg = await finalImage.readAsBytes();
          formData = FormData({'image': MultipartFile(byteImg, filename: fileName)});
        } else {
          String filePath = finalImage.path;
          String fileName = filePath.split('/').last;
          formData = FormData({'image': await MultipartFile(filePath, filename: fileName)});
        }

        final url = await service.uploadImage(
            imageData: formData, endpoint: 'categories/upload-image');
        if (url != null) {
          uploadedImageUrl = url;
          print('Image uploaded: $url');
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to upload image.');
          selectedImage = null;
        }
      } catch (e) {
        print('Image upload error: $e');
        SnackBarHelper.showErrorSnackBar('Error uploading image: $e');
        selectedImage = null;
      } finally {
        isImageUploading = false;
        notifyListeners();
      }
    }
  }

  deleteSubSubCategory(SubSubCategory subSubCategory) async {
    try {
      final response = await service.deleteItem(
          endpointUrl: 'subSubCategories', itemId: subSubCategory.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(
              'Sub SubCategory Deleted Successfully');
          print('[SubSubCategory] Deleted successfully');
          _dataProvider.getAllSubSubCategory(); // refresh in background
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('[SubSubCategory] Delete exception: $e');
      SnackBarHelper.showErrorSnackBar('Failed to delete: $e');
    }
  }

  setDataForUpdateSubSubCategory(SubSubCategory? subSubCategory) {
    if (subSubCategory != null) {
      subSubCategoryForUpdate = subSubCategory;
      subSubCategoryNameCtrl.text = subSubCategory.name ?? '';
      selectedCategory = _dataProvider.categories.firstWhereOrNull(
          (element) => element.sId == subSubCategory.categoryId?.sId);
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == subSubCategory.subCategoryId?.sId);
      uploadedImageUrl = subSubCategory.image;
    } else {
      clearFields();
    }
  }

  clearFields() {
    subSubCategoryNameCtrl.clear();
    selectedCategory = null;
    selectedSubCategory = null;
    subSubCategoryForUpdate = null;
    selectedImage = null;
    uploadedImageUrl = null;
    isImageUploading = false;
  }

  updateUi() {
    notifyListeners();
  }
}
