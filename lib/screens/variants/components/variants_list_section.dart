import 'package:admin/utility/extensions.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';
import 'add_variant_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import '../../../models/variant_type.dart';


class VariantsListSection extends StatefulWidget {
  const VariantsListSection({
    Key? key,
  }) : super(key: key);

  @override
  State<VariantsListSection> createState() => _VariantsListSectionState();
}

class _VariantsListSectionState extends State<VariantsListSection> {
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
              "All Variants",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final allVariants = dataProvider.variants;
                final displayedVariants =
                    allVariants.take(visibleCount).toList();

                return Column(
                  children: [
                    DataTable(
                      //columnSpacing: defaultPadding,
                      horizontalMargin: 12, // small edge padding
                      columnSpacing: 160, // BIG spacing between columns
                      // minWidth: 600,
                      columns: [
                        DataColumn(
                          label: Text("Variant"),
                        ),
                        DataColumn(
                          label: Text("Variant Type"),
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
                        displayedVariants.length,
                        (index) => variantDataRow(
                            displayedVariants[index], index + 1, edit: () {
                          showAddVariantForm(context, displayedVariants[index]);
                        }, delete: () {
                          //TODO: should complete call deleteVariant
                          context.variantProvider
                              .deleteVariant(displayedVariants[index]);
                        }),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (visibleCount < allVariants.length)
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
                        if (visibleCount < allVariants.length)
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
                                visibleCount = allVariants.length;
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

DataRow variantDataRow(Variant VariantInfo, int index, {Function? edit, Function? delete}) {
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
              child: Text(VariantInfo.name ?? ''),
            ),
          ],
        ),
      ),
      DataCell(Text(VariantInfo.variantTypeId?.name ?? '')),
      DataCell(Text(VariantInfo.createdAt ?? '')),
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
