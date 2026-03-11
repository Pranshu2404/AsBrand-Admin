import 'package:admin/core/data/data_provider.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/sub_sub_category.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import '../provider/sub_sub_category_provider.dart';
import 'add_sub_sub_category_form.dart';

class SubSubCategoryListSection extends StatelessWidget {
  const SubSubCategoryListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All Sub SubCategories",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                return DataTable(
                  columnSpacing: defaultPadding,
                  columns: [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Sub Category")),
                    DataColumn(label: Text("Category")),
                    DataColumn(label: Text("Added Date")),
                    DataColumn(label: Text("Edit")),
                    DataColumn(label: Text("Delete")),
                  ],
                  rows: List.generate(
                    dataProvider.subSubCategories.length,
                    (index) => subSubCategoryDataRow(
                        dataProvider.subSubCategories[index], context),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow subSubCategoryDataRow(SubSubCategory subSubCategory, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            (subSubCategory.image != null && subSubCategory.image != 'no_url')
              ? Image.network(
                  subSubCategory.image!,
                  height: 30,
                  width: 30,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return const Icon(Icons.error);
                  },
                )
              : const SizedBox(
                  height: 30,
                  width: 30,
                  child: Icon(Icons.image, color: Colors.grey),
                ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(subSubCategory.name ?? ''),
            ),
          ],
        ),
      ),
      DataCell(Text(subSubCategory.subCategoryId?.name ?? '')),
      DataCell(Text(subSubCategory.categoryId?.name ?? '')),
      DataCell(Text(subSubCategory.createdAt?.substring(0, 10) ?? '')),
      DataCell(
        IconButton(
          onPressed: () {
            showAddSubSubCategoryForm(context, subSubCategory);
          },
          icon: Icon(Icons.edit, color: Colors.white),
        ),
      ),
      DataCell(
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: bgColor,
                  title: Text('Confirmation', style: TextStyle(color: Colors.white)),
                  content: Text('Are you sure you want to delete this sub subcategory?', style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        context.subSubCategoryProvider.deleteSubSubCategory(subSubCategory);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    ],
  );
}
