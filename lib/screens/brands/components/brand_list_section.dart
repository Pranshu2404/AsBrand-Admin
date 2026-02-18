import 'package:admin/utility/extensions.dart';

import '../../../core/data/data_provider.dart';
import 'add_brand_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import '../../../models/brand.dart';

class BrandListSection extends StatefulWidget {
  const BrandListSection({
    Key? key,
  }) : super(key: key);

  @override
  State<BrandListSection> createState() => _BrandListSectionState();
}

class _BrandListSectionState extends State<BrandListSection> {
  int visibleCount = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "All Brands",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final allBrands = dataProvider.brands;
                final displayedBrands = allBrands.take(visibleCount).toList();

                return Column(
                  children: [
                    DataTable(
                      //columnSpacing: defaultPadding,
                      horizontalMargin: 12, // small edge padding
                      columnSpacing: 170, // BIG spacing between columns
                      // minWidth: 600,
                      columns: [
                        DataColumn(
                          label: Text("Brands Name"),
                        ),
                        DataColumn(
                          label: Text("Sub Category"),
                        ),
                        DataColumn(
                          label: Text("Added Date"),
                        ),
                        DataColumn(
                          label: Text("Edit"),
                        ),
                        DataColumn(
                          label: Text("Delete"),
                        ),
                      ],
                      rows: List.generate(
                        displayedBrands.length,
                        (index) => brandDataRow(
                            displayedBrands[index], index + 1, edit: () {
                          showBrandForm(context, displayedBrands[index]);
                        }, delete: () {
                          //TODO: should complete deleteBrand
                          context.brandProvider
                              .deleteBrand(displayedBrands[index]);
                        }),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (visibleCount < allBrands.length)
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical: defaultPadding / 2,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                visibleCount += 10;
                              });
                            },
                            child: const Text("See More",
                                style: TextStyle(color: Colors.white)),
                          ),
                        const SizedBox(width: defaultPadding),
                        if (visibleCount < allBrands.length)
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical: defaultPadding / 2,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                visibleCount = allBrands.length;
                              });
                            },
                            child: const Text("Show All",
                                style: TextStyle(color: Colors.white)),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow brandDataRow(Brand brandInfo, int index, {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
              child: Text(index.toString(), textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(brandInfo.name!),
            ),
          ],
        ),
      ),
      DataCell(Text(brandInfo.subcategoryId?.name ?? '')),
      DataCell(Text(brandInfo.createdAt ?? '')),
      DataCell(IconButton(
          onPressed: () {
            if (edit != null) edit();
          },
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ))),
      DataCell(IconButton(
          onPressed: () {
            if (delete != null) delete();
          },
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ))),
    ],
  );
}
