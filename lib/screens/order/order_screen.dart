import 'components/order_header.dart';
import 'components/order_list_section.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utility/constants.dart';
import '../../widgets/custom_dropdown.dart';
import '../../core/data/data_provider.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
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
                OrderHeader(),
                SizedBox(height: defaultPadding),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  "My Orders",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Gap(20),
                              SizedBox(
                                width: 280,
                                child: CustomDropdown(
                                  hintText: 'Filter Order By status',
                                  initialValue: Provider.of<DataProvider>(context).selectedOrderFilter,
                                  items: ['All order', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'],
                                  displayItem: (val) => val,
                                  onChanged: (newValue) {
                                    if (newValue?.toLowerCase() == 'all order') {
                                      Provider.of<DataProvider>(context, listen: false).filterOrders('');
                                    } else {
                                      Provider.of<DataProvider>(context, listen: false).filterOrders(newValue ?? '');
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select status';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Gap(40),
                              Consumer<DataProvider>(
                                builder: (context, dataProvider, child) {
                                  return IconButton(
                                    onPressed: dataProvider.isRefreshing ? null : () async {
                                      dataProvider.setRefreshing(true);
                                      try {
                                        await Provider.of<DataProvider>(context, listen: false).getAllOrders(showSnack: true);
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
                          OrderListSection(),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
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
