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

  // Get statistics
  int get totalUsers => _allUsers.length;
  int get adminCount => _allUsers.where((u) => u.isAdmin).length;
  int get customerCount => _allUsers.where((u) => !u.isAdmin).length;
}
