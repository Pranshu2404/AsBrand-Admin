import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../utility/constants.dart';
import '../../core/data/data_provider.dart';
import 'components/notification_header.dart';
import 'components/notification_list_section.dart';
import 'components/send_notification_form.dart';


class NotificationScreen extends StatelessWidget {
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
                NotificationHeader(),
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
                                  "My Notification",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              ElevatedButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 1.5,
                                    vertical: defaultPadding,
                                  ),
                                ),
                                onPressed: () {
                                  sendNotificationFormForm(context);
                                },
                                icon: Icon(Icons.add),
                                label: Text("Send New"),
                              ),
                              Gap(20),
                              Consumer<DataProvider>(
                                builder: (context, dataProvider, child) {
                                  return IconButton(
                                    onPressed: dataProvider.isRefreshing ? null : () async {
                                      dataProvider.setRefreshing(true);
                                      try {
                                        // Notification refresh - no specific API yet
                                        await Future.delayed(const Duration(milliseconds: 500));
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
                          NotificationListSection(),
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
