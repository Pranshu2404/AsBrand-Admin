import 'package:admin/utility/extensions.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/product.dart';
import 'add_product_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';

class ProductListSection extends StatefulWidget {
  const ProductListSection({
    Key? key,
  }) : super(key: key);

  @override
  State<ProductListSection> createState() => _ProductListSectionState();
}

class _ProductListSectionState extends State<ProductListSection> {
  // This is UI-based pagination. For server-side pagination,
  // the DataProvider would need to be modified to fetch data in chunks.
  int visibleProductCount = 10;

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
              "All Products",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final allProducts = dataProvider.products;
                final displayedProducts =
                    allProducts.take(visibleProductCount).toList();

                return Column(
                  children: [
                    DataTable(
                      //columnSpacing: defaultPadding,
                      horizontalMargin: 0,
                      // minWidth: 600,
                      columns: [
                        DataColumn(
                          label: Text("Product Name"),
                        ),
                        DataColumn(
                          label: Text("Category"),
                        ),
                        DataColumn(
                          label: Text("Sub Category"),
                        ),
                        DataColumn(
                          label: Text("Price"),
                        ),
                        DataColumn(
                          label: Text("Edit"),
                        ),
                        DataColumn(
                          label: Text("Delete"),
                        ),
                      ],
                      rows: List.generate(
                        displayedProducts.length,
                        (index) => productDataRow(
                          displayedProducts[index],
                          edit: () {
                            showAddProductForm(context, displayedProducts[index]);
                          },
                          delete: () async {
                            context.dataProvider.setRefreshing(true);
                            try {
                              await context.dashBoardProvider
                                  .deleteProduct(displayedProducts[index]);
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
                        if (visibleProductCount < allProducts.length)
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
                                visibleProductCount += 10;
                              });
                            },
                            child: const Text("See More", style: TextStyle(color: Colors.white),),
                          ),
                        const SizedBox(width: defaultPadding),
                        if (visibleProductCount < allProducts.length)
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
                                visibleProductCount = allProducts.length;
                              });
                            },
                            child: const Text("Show All", style: TextStyle(color: Colors.white),),
                          ),
                      ],
                    )
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

DataRow productDataRow(Product productInfo,{Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Image.network(
              productInfo.images?.first.url ?? '',
              height: 30,
              width: 30,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Icon(Icons.error);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(productInfo.name ?? ''),
            ),
          ],
        ),
      ),
      DataCell(Text(productInfo.proCategoryId?.name ?? '')),
      DataCell(Text(productInfo.proSubCategoryId?.name ?? '')),
      DataCell(Text('${productInfo.price}'),),
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
