import 'dart:developer';
import 'package:admin/services/file_handling/file_service.dart';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/poster.dart';

class PosterProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addPosterFormKey = GlobalKey<FormState>();
  TextEditingController posterNameCtrl = TextEditingController();
  Poster? posterForUpdate;

  AppFile? selectedImage;
  XFile? imgXFile;

  PosterProvider(this._dataProvider);

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  //TODO: should complete addPoster
  addPoster() async {
    try {
      _isSubmitting = true;
      notifyListeners();
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar('Please Choose An Image!');
        return;
      }

      Map<String, dynamic> formDataMap = {
        'posterName': posterNameCtrl.text,
        'image': 'no_data', // Image path will be added from server side
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response =
          await service.addItem(endpointUrl: 'posters', itemData: form);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          print('[Poster] Added successfully');
          _dataProvider.getAllPosters(); // refresh in background
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add poster: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  //TODO: should complete updatePoster
  updatePoster() async {
    try {
      _isSubmitting = true;
      notifyListeners();
      Map<String, dynamic> formDataMap = {
        'posterName': posterNameCtrl.text,
        'image': posterForUpdate?.imageUrl ?? '',
      };

      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      final response = await service.updateItem(
        endpointUrl: 'posters',
        itemData: form,
        itemId: posterForUpdate?.sId ?? '',
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
            '${apiResponse.message}',
          );
          print('[Poster] Updated successfully');
          _dataProvider.getAllPosters(); // refresh in background
        } else {
          SnackBarHelper.showErrorSnackBar(
            'Failed to add poster: ${apiResponse.message}',
          );
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          'Error ${response.body?['message'] ?? response.statusText}',
        );
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  //TODO: should complete submitPoster
  Future<void> submitPoster() async {
    if (posterForUpdate == null) {
      await addPoster();
    } else {
      await updatePoster();
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

  //TODO: should complete deletePoster
  deletePoster(Poster poster) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'posters', itemId: poster.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Poster Deleted Successfully');
          print('[Poster] Deleted successfully');
          _dataProvider.getAllPosters(); // refresh in background
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  setDataForUpdatePoster(Poster? poster) {
    if (poster != null) {
      clearFields();
      posterForUpdate = poster;
      posterNameCtrl.text = poster.posterName ?? '';
    } else {
      clearFields();
    }
  }

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

  clearFields() {
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    posterForUpdate = null;
  }
}
