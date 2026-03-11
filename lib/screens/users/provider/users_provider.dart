import 'dart:developer';
import 'package:admin/models/api_response.dart';
import 'package:admin/models/app_user.dart';
import 'package:admin/services/http_services.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<AppUser> _allUsers = [];
  List<AppUser> _filteredUsers = [];
  List<AppUser> get users => _filteredUsers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Get all users
  Future<void> getAllUsers({bool showSnack = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response response = await service.getItems(endpointUrl: 'users');
      if (response.isOk) {
        ApiResponse<List<AppUser>> apiResponse = ApiResponse<List<AppUser>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => AppUser.fromJson(item)).toList(),
        );
        _allUsers = apiResponse.data ?? [];
        _filteredUsers = List.from(_allUsers);
        notifyListeners();
        if (showSnack) SnackBarHelper.showSuccessSnackBar('${_allUsers.length} users loaded');
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      log('Error fetching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter users
  void filterUsers(String keyword) {
    if (keyword.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredUsers = _allUsers.where((user) {
        return (user.name ?? '').toLowerCase().contains(lowerKeyword) ||
            (user.email ?? '').toLowerCase().contains(lowerKeyword) ||
            (user.phone ?? '').contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  // Delete user
  Future<void> deleteUser(AppUser user) async {
    try {
      Response response = await service.deleteItem(endpointUrl: 'users', itemId: user.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          getAllUsers();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to delete user: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      log('Delete User Exception: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }

  // Update user role
  Future<void> updateUserRole(AppUser user, String newRole) async {
    try {
      Map<String, dynamic> data = {'role': newRole};
      Response response = await service.updateItem(endpointUrl: 'users', itemId: '${user.sId}/role', itemData: data);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          getAllUsers();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to update role: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      log('Update Role Exception: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }

  // Get statistics
  int get totalUsers => _allUsers.length;
  int get adminCount => _allUsers.where((u) => u.role == 'admin').length;
  int get customerCount => _allUsers.where((u) => u.role == 'user').length;
  int get supplierCount => _allUsers.where((u) => u.role == 'supplier').length;
}
