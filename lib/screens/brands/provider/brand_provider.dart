import 'dart:developer';

import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../models/brand.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/file_handling/file_service.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';

class BrandProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addBrandFormKey = GlobalKey<FormState>();
  TextEditingController brandNameCtrl = TextEditingController();
  SubCategory? selectedSubCategory;
  Brand? brandForUpdate;

  BrandProvider(this._dataProvider);

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  AppFile? selectedImage;
  String? uploadedImageUrl;
  bool isImageUploading = false;

  //TODO: should complete addBrand
  addBrand() async {
    try {
      _isSubmitting = true;
      notifyListeners();
      Map<String, dynamic> brand = {
        'name': brandNameCtrl.text,
        'subcategoryId': selectedSubCategory?.sId,
        'image': uploadedImageUrl ?? 'no_url'
      };

      final response =
          await service.addItem(endpointUrl: 'brands', itemData: brand);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          print('[Brand] Added successfully');
          _dataProvider.getAllBrands(); // refresh in background
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add Brand: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('[Brand] Add exception: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  //TODO: should complete updateBrand
  updateBrand() async {
    try {
      _isSubmitting = true;
      notifyListeners();
      if (brandForUpdate != null) {
        Map<String, dynamic> brand = {
          'name': brandNameCtrl.text,
          'subcategoryId': selectedSubCategory?.sId,
          'image': uploadedImageUrl ?? brandForUpdate?.image ?? 'no_url'
        };

        final response = await service.updateItem(
            endpointUrl: 'brands',
            itemData: brand,
            itemId: brandForUpdate?.sId ?? '');

        if (response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if (apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            print('[Brand] Updated successfully');
            _dataProvider.getAllBrands(); // refresh in background
          } else {
            SnackBarHelper.showErrorSnackBar(
                'Failed to update Brand: ${apiResponse.message}');
          }
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (e) {
      print('[Brand] Update exception: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  //TODO: should complete submitBrand
  Future<void> submitBrand() async {
    if (brandForUpdate == null) {
      await addBrand();
    } else {
      await updateBrand();
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

  deleteBrand(Brand brand) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'brands', itemId: brand.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Brand Deleted Successfully');
          print('[Brand] Deleted successfully');
          _dataProvider.getAllBrands(); // refresh in background
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('[Brand] Delete exception: $e');
      SnackBarHelper.showErrorSnackBar('Failed to delete: $e');
    }
  }

  //? set data for update on editing
  setDataForUpdateBrand(Brand? brand) {
    if (brand != null) {
      brandForUpdate = brand;
      brandNameCtrl.text = brand.name ?? '';
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == brand.subcategoryId?.sId);
      uploadedImageUrl = brand.image;
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update brand
  clearFields() {
    brandNameCtrl.clear();
    selectedSubCategory = null;
    brandForUpdate = null;
    selectedImage = null;
    uploadedImageUrl = null;
    isImageUploading = false;
  }

  updateUI() {
    notifyListeners();
  }
}
