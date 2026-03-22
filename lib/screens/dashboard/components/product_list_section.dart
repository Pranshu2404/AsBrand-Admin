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
  String imageUrl = '';
  if (productInfo.images != null && productInfo.images!.isNotEmpty) {
    imageUrl = productInfo.images!.first.url ?? '';
  } else if (productInfo.skus != null && productInfo.skus!.isNotEmpty) {
    for (var sku in productInfo.skus!) {
      if (sku is Map) {
        final skuImages = sku['images'];
        if (skuImages != null && skuImages is List && skuImages.isNotEmpty) {
          final firstImg = skuImages.first;
          if (firstImg is String && firstImg.isNotEmpty) {
            imageUrl = firstImg;
            break;
          } else if (firstImg is Map && firstImg['url'] != null) {
            imageUrl = firstImg['url'].toString();
            break;
          }
        }
      }
    }
  }

  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 30,
                    width: 30,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(
                        height: 30,
                        width: 30,
                        color: Colors.grey[700],
                        child: Icon(Icons.image_not_supported, size: 18, color: Colors.grey[400]),
                      );
                    },
                  )
                : Container(
                    height: 30,
                    width: 30,
                    color: Colors.grey[700],
                    child: Icon(Icons.image_not_supported, size: 18, color: Colors.grey[400]),
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
      DataCell(Builder(builder: (context) {
        return IconButton(
            onPressed: () async {
              // Show confirmation dialog before deleting
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E2030),
                  title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
                  content: Text(
                    'Do you want to delete "${productInfo.name ?? 'this product'}"? This action cannot be undone.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && delete != null) {
                delete();
              }
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ));
      })),
    ],
  );
}
