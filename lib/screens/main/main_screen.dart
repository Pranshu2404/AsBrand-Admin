import 'provider/main_screen_provider.dart';
import '../../utility/extensions.dart';
import '../../utility/constants.dart';
import '../../core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/side_menu.dart';


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.dataProvider;
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SideMenu(),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // Top header bar with logout
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      border: Border(
                        bottom: BorderSide(color: Colors.white12, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Colors.white54, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Admin',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                backgroundColor: secondaryColor,
                                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                                content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Logout', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', false);
                              Get.offAllNamed(AppPages.LOGIN);
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                          label: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  // Main content area
                  Expanded(
                    child: Consumer<MainScreenProvider>(
                      builder: (context, provider, child) {
                        return provider.selectedScreen;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
