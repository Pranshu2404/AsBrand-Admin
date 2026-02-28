import 'package:admin/utility/extensions.dart';

import '../../../core/data/data_provider.dart';
import 'add_variant_type_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import '../../../models/variant_type.dart';


class VariantsTypeListSection extends StatefulWidget {
  const VariantsTypeListSection({
    Key? key,
  }) : super(key: key);

  @override
  State<VariantsTypeListSection> createState() =>
      _VariantsTypeListSectionState();
}

class _VariantsTypeListSectionState extends State<VariantsTypeListSection> {
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
              "All Variants Type",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final allVariantTypes = List.from(dataProvider.variantTypes.reversed);
                final displayedVariantTypes =
                    allVariantTypes.take(visibleCount).toList();

                return Column(
                  children: [
                    DataTable(
                      //columnSpacing: defaultPadding,
                      horizontalMargin: 12, // small edge padding
                      columnSpacing: 150, // BIG spacing between columns
                      // minWidth: 600,
                      columns: [
                        DataColumn(
                          label: Text("Variant Name"),
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
                        displayedVariantTypes.length,
                        (index) => variantTypeDataRow(
                          displayedVariantTypes[index],
                          index + 1,
                          edit: () {
                            showAddVariantsTypeForm(
                                context, displayedVariantTypes[index]);
                          },
                          delete: () async {
                            context.dataProvider.setRefreshing(true);
                            try {
                              await context.variantTypeProvider.deleteVariantType(
                                  displayedVariantTypes[index]);
                            } finally {
                              context.dataProvider.setRefreshing(false);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (visibleCount < allVariantTypes.length)
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
                        if (visibleCount < allVariantTypes.length)
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
                                visibleCount = allVariantTypes.length;
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

DataRow variantTypeDataRow(VariantType VariantTypeInfo, int index, {Function? edit, Function? delete}) {
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
              child: Text(VariantTypeInfo.name ?? ''),
            ),
          ],
        ),
      ),
      DataCell(Text(VariantTypeInfo.type ?? '')),
      DataCell(Text(_formatDate(VariantTypeInfo.createdAt))),
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

String _formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  try {
    final dt = DateTime.parse(isoDate).toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  } catch (_) {
    return isoDate;
  }
}
