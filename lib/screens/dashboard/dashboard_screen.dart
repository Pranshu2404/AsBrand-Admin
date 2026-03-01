import 'package:admin/utility/extensions.dart';
import 'package:provider/provider.dart';

import 'components/dash_board_header.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utility/constants.dart';
import '../../core/data/data_provider.dart';
import 'components/add_product_form.dart';
import 'components/order_details_section.dart';
import 'components/product_list_section.dart';
import 'components/product_summery_section.dart';
import 'components/product_filter_section.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                DashBoardHeader(),
                Gap(defaultPadding),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "My Products",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              ElevatedButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 1.5,
                                    vertical: defaultPadding,
                                  ),
                                ),
                                onPressed: () {
                                  showAddProductForm(context, null);
                                },
                                icon: Icon(Icons.add, color: Colors.white),
                                label: Text("Add New Product", style: TextStyle(color: Colors.white)),
                              ),
                              Gap(20),
                              Consumer<DataProvider>(
                                builder: (context, dataProvider, child) {
                                  return IconButton(
                                    onPressed: dataProvider.isRefreshing ? null : () async {
                                      dataProvider.setRefreshing(true);
                                      try {
                                        await context.dataProvider.getAllProduct(showSnack: true);
                                      } finally {
                                        dataProvider.setRefreshing(false);
                                      }
                                    },
                                    icon: dataProvider.isRefreshing
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.refresh),
                                  );
                                },
                              ),
                            ],
                          ),
                          Gap(defaultPadding),
                          ProductSummerySection(),
                          Gap(defaultPadding),
                          Gap(defaultPadding),
                          ProductFilterSection(),
                          Gap(defaultPadding),
                          ProductListSection(),
                        ],
                      ),
                    ),
                    SizedBox(width: defaultPadding),
                    Expanded(
                      flex: 2,
                      child: OrderDetailsSection(),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Full-screen loading overlay
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              if (!dataProvider.isRefreshing) return const SizedBox.shrink();
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
