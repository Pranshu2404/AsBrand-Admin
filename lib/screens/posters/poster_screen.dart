import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../utility/constants.dart';
import '../../core/data/data_provider.dart';
import 'components/add_poster_form.dart';
import 'components/poster_header.dart';
import 'components/poster_list_section.dart';


class PosterScreen extends StatelessWidget {
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
                PosterHeader(),
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
                                  "My Posters",
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
                                  showAddPosterForm(context, null);
                                },
                                icon: Icon(Icons.add, color: Colors.white),
                                label: Text("Add New", style: TextStyle(color: Colors.white)),
                              ),
                              Gap(20),
                              Consumer<DataProvider>(
                                builder: (context, dataProvider, child) {
                                  return IconButton(
                                    onPressed: dataProvider.isRefreshing ? null : () async {
                                      dataProvider.setRefreshing(true);
                                      try {
                                        await context.dataProvider.getAllPosters(showSnack: true);
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
                          PosterListSection(),
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
