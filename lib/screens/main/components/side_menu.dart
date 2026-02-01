import '../../../utility/extensions.dart';
import '../../../utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/main_screen_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainScreenProvider>(
      builder: (context, mainProvider, _) {
        return Drawer(
          backgroundColor: bgColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              DrawerHeader(
                decoration: BoxDecoration(
                  color: secondaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/logo.png", height: 50),
                    const SizedBox(height: 10),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Main Section
              _buildSectionLabel('MAIN'),
              _buildMenuItem(
                context: context,
                title: 'Dashboard',
                icon: 'assets/icons/menu_dashboard.svg',
                isSelected: mainProvider.currentScreenName == 'Dashboard',
                onTap: () => context.mainScreenProvider.navigateToScreen('Dashboard'),
              ),
              
              // Catalog Section
              _buildSectionLabel('CATALOG'),
              _buildMenuItem(
                context: context,
                title: 'Category',
                icon: 'assets/icons/menu_tran.svg',
                isSelected: mainProvider.currentScreenName == 'Category',
                onTap: () => context.mainScreenProvider.navigateToScreen('Category'),
              ),
              _buildMenuItem(
                context: context,
                title: 'Sub Category',
                icon: 'assets/icons/menu_task.svg',
                isSelected: mainProvider.currentScreenName == 'SubCategory',
                onTap: () => context.mainScreenProvider.navigateToScreen('SubCategory'),
              ),
              _buildMenuItem(
                context: context,
                title: 'Brands',
                icon: 'assets/icons/menu_doc.svg',
                isSelected: mainProvider.currentScreenName == 'Brands',
                onTap: () => context.mainScreenProvider.navigateToScreen('Brands'),
              ),
              _buildMenuItem(
                context: context,
                title: 'Variant Type',
                icon: 'assets/icons/menu_store.svg',
                isSelected: mainProvider.currentScreenName == 'VariantType',
                onTap: () => context.mainScreenProvider.navigateToScreen('VariantType'),
              ),
              _buildMenuItem(
                context: context,
                title: 'Variants',
                icon: 'assets/icons/menu_notification.svg',
                isSelected: mainProvider.currentScreenName == 'Variants',
                onTap: () => context.mainScreenProvider.navigateToScreen('Variants'),
              ),
              
              // Sales Section
              _buildSectionLabel('SALES'),
              _buildMenuItem(
                context: context,
                title: 'Orders',
                icon: 'assets/icons/menu_profile.svg',
                isSelected: mainProvider.currentScreenName == 'Order',
                onTap: () => context.mainScreenProvider.navigateToScreen('Order'),
              ),
              _buildMenuItem(
                context: context,
                title: 'Coupons',
                icon: 'assets/icons/menu_setting.svg',
                isSelected: mainProvider.currentScreenName == 'Coupon',
                onTap: () => context.mainScreenProvider.navigateToScreen('Coupon'),
              ),
              
              // Marketing Section
              _buildSectionLabel('MARKETING'),
              _buildMenuItem(
                context: context,
                title: 'Posters',
                icon: 'assets/icons/menu_doc.svg',
                isSelected: mainProvider.currentScreenName == 'Poster',
                onTap: () => context.mainScreenProvider.navigateToScreen('Poster'),
              ),
              _buildMenuItem(
                context: context,
                title: 'Notifications',
                icon: 'assets/icons/menu_notification.svg',
                isSelected: mainProvider.currentScreenName == 'Notifications',
                onTap: () => context.mainScreenProvider.navigateToScreen('Notifications'),
              ),
              
              // BNPL Section
              _buildSectionLabel('BNPL & USERS'),
              _buildMenuItem(
                context: context,
                title: 'EMI Plans',
                icon: 'assets/icons/menu_setting.svg',
                isSelected: mainProvider.currentScreenName == 'EmiPlans',
                onTap: () => context.mainScreenProvider.navigateToScreen('EmiPlans'),
              ),
              _buildMenuItem(
                context: context,
                title: 'KYC Management',
                icon: 'assets/icons/menu_doc.svg',
                isSelected: mainProvider.currentScreenName == 'Kyc',
                onTap: () => context.mainScreenProvider.navigateToScreen('Kyc'),
              ),
              _buildMenuItem(
                context: context,
                title: 'Users',
                icon: 'assets/icons/menu_profile.svg',
                isSelected: mainProvider.currentScreenName == 'Users',
                onTap: () => context.mainScreenProvider.navigateToScreen('Users'),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading: SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(
            isSelected ? primaryColor : Colors.white54,
            BlendMode.srcIn,
          ),
          height: 18,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
      ),
    );
  }
}
