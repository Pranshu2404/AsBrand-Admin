import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import '../provider/dash_board_provider.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/multi_select_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/product_image_card.dart';
import 'package:gap/gap.dart';

class ProductSubmitForm extends StatefulWidget {
  final Product? product;

  const ProductSubmitForm({super.key, this.product});

  @override
  State<ProductSubmitForm> createState() => _ProductSubmitFormState();
}

class _ProductSubmitFormState extends State<ProductSubmitForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    context.dashBoardProvider.setDataForUpdateProduct(widget.product);
    
    return SingleChildScrollView(
      child: Form(
        key: context.dashBoardProvider.addProductFormKey,
        child: Container(
          width: size.width * 0.8,
          height: size.height * 0.85,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: primaryColor,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.white54,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Basic Info', icon: Icon(Icons.info_outline, size: 18)),
                    Tab(text: 'Pricing', icon: Icon(Icons.attach_money, size: 18)),
                    Tab(text: 'Inventory', icon: Icon(Icons.inventory_2_outlined, size: 18)),
                    Tab(text: 'Details', icon: Icon(Icons.list_alt, size: 18)),
                    Tab(text: 'Media', icon: Icon(Icons.image_outlined, size: 18)),
                    Tab(text: 'SEO', icon: Icon(Icons.search, size: 18)),
                  ],
                ),
              ),
              const Gap(defaultPadding),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicInfoTab(context),
                    _buildPricingTab(context),
                    _buildInventoryTab(context),
                    _buildDetailsTab(context),
                    _buildMediaTab(context),
                    _buildSeoTab(context),
                  ],
                ),
              ),
              
              // Action Buttons
              const Gap(defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const Gap(defaultPadding),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      if (context.dashBoardProvider.addProductFormKey.currentState!.validate()) {
                        context.dashBoardProvider.addProductFormKey.currentState!.save();
                        context.dashBoardProvider.submitProduct();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(widget.product != null ? 'Update Product' : 'Create Product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 1: Basic Info
  Widget _buildBasicInfoTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Product Information'),
          CustomTextField(
            controller: context.dashBoardProvider.productNameCtrl,
            labelText: 'Product Name *',
            onSave: (val) {},
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter name';
              return null;
            },
          ),
          const Gap(defaultPadding),
          CustomTextField(
            controller: context.dashBoardProvider.productDescCtrl,
            labelText: 'Product Description',
            lineNumber: 4,
            onSave: (val) {},
          ),
          const Gap(defaultPadding),
          
          _sectionHeader('Categorization'),
          Row(
            children: [
              Expanded(child: Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return CustomDropdown(
                    key: ValueKey(dashProvider.selectedCategory?.sId),
                    initialValue: dashProvider.selectedCategory,
                    hintText: dashProvider.selectedCategory?.name ?? 'Select category',
                    items: context.dataProvider.categories,
                    displayItem: (Category? category) => category?.name ?? '',
                    onChanged: (newValue) {
                      if (newValue != null) {
                        context.dashBoardProvider.filterSubcategory(newValue);
                      }
                    },
                    validator: (value) {
                      if (value == null) return 'Please select a category';
                      return null;
                    },
                  );
                },
              )),
              const Gap(defaultPadding),
              Expanded(child: Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return CustomDropdown(
                    key: ValueKey(dashProvider.selectedSubCategory?.sId),
                    hintText: dashProvider.selectedSubCategory?.name ?? 'Sub category',
                    items: dashProvider.subCategoriesByCategory,
                    initialValue: dashProvider.selectedSubCategory,
                    displayItem: (SubCategory? subCategory) => subCategory?.name ?? '',
                    onChanged: (newValue) {
                      if (newValue != null) {
                        context.dashBoardProvider.filterBrand(newValue);
                      }
                    },
                    validator: (value) {
                      if (value == null) return 'Please select sub category';
                      return null;
                    },
                  );
                },
              )),
            ],
          ),
          const Gap(defaultPadding),
          Row(
            children: [
              Expanded(
                child: Consumer<DashBoardProvider>(
                  builder: (context, dashProvider, child) {
                    return CustomDropdown(
                      key: ValueKey(dashProvider.selectedBrand?.sId),
                      initialValue: dashProvider.selectedBrand,
                      items: dashProvider.brandsBySubCategory,
                      hintText: dashProvider.selectedBrand?.name ?? 'Select Brand',
                      displayItem: (Brand? brand) => brand?.name ?? '',
                      onChanged: (newValue) {
                        if (newValue != null) {
                          dashProvider.selectedBrand = newValue;
                          dashProvider.updateUI();
                        }
                      },
                      validator: (value) {
                        if (value == null) return 'Please select brand';
                        return null;
                      },
                    );
                  },
                ),
              ),
              const Gap(defaultPadding),
              Expanded(child: Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return SwitchListTile(
                    title: const Text('Featured Product'),
                    subtitle: const Text('Show on homepage'),
                    value: dashProvider.isFeatured,
                    activeColor: primaryColor,
                    onChanged: (val) {
                      dashProvider.isFeatured = val;
                      dashProvider.updateUI();
                    },
                  );
                },
              )),
            ],
          ),
        ],
      ),
    );
  }

  // Tab 2: Pricing
  Widget _buildPricingTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Pricing Information'),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productPriceCtrl,
                  labelText: 'Regular Price (₹) *',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter price';
                    return null;
                  },
                ),
              ),
              const Gap(defaultPadding),
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productOffPriceCtrl,
                  labelText: 'Offer Price (₹)',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                ),
              ),
            ],
          ),
          const Gap(defaultPadding),
          
          _sectionHeader('Payment Options'),
          Consumer<DashBoardProvider>(
            builder: (context, dashProvider, child) {
              return Container(
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SwitchListTile(
                  title: const Text('EMI Eligible'),
                  subtitle: const Text('Allow Buy Now Pay Later for this product'),
                  value: dashProvider.isEmiEligible,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    dashProvider.isEmiEligible = val;
                    dashProvider.updateUI();
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: dashProvider.isEmiEligible ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: dashProvider.isEmiEligible ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const Gap(defaultPadding * 2),
          _sectionHeader('Variants'),
          Row(
            children: [
              Expanded(
                child: Consumer<DashBoardProvider>(
                  builder: (context, dashProvider, child) {
                    return CustomDropdown(
                      key: ValueKey(dashProvider.selectedVariantType?.sId),
                      initialValue: dashProvider.selectedVariantType,
                      items: context.dataProvider.variantTypes,
                      displayItem: (VariantType? variantType) => variantType?.name ?? '',
                      onChanged: (newValue) {
                        if (newValue != null) {
                          context.dashBoardProvider.filterVariant(newValue);
                        }
                      },
                      hintText: 'Select Variant type',
                    );
                  },
                ),
              ),
              const Gap(defaultPadding),
              Expanded(
                child: Consumer<DashBoardProvider>(
                  builder: (context, dashProvider, child) {
                    final filteredSelectedItems =
                        dashProvider.selectedVariants.where((item) => dashProvider.variantsByVariantType.contains(item)).toList();
                    return MultiSelectDropDown(
                      items: dashProvider.variantsByVariantType,
                      onSelectionChanged: (newValue) {
                        dashProvider.selectedVariants = newValue;
                        dashProvider.updateUI();
                      },
                      displayItem: (String item) => item,
                      selectedItems: filteredSelectedItems,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tab 3: Inventory
  Widget _buildInventoryTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Stock Management'),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productSkuCtrl,
                  labelText: 'SKU (Stock Keeping Unit)',
                  onSave: (val) {},
                ),
              ),
              const Gap(defaultPadding),
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productQntCtrl,
                  labelText: 'Quantity *',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter quantity';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const Gap(defaultPadding),
          Row(
            children: [
              Expanded(child: Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return DropdownButtonFormField<String>(
                    value: dashProvider.stockStatus,
                    decoration: const InputDecoration(
                      labelText: 'Stock Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'in_stock', child: Text('In Stock')),
                      DropdownMenuItem(value: 'out_of_stock', child: Text('Out of Stock')),
                      DropdownMenuItem(value: 'low_stock', child: Text('Low Stock')),
                      DropdownMenuItem(value: 'pre_order', child: Text('Pre-Order')),
                    ],
                    onChanged: (val) {
                      dashProvider.stockStatus = val ?? 'in_stock';
                      dashProvider.updateUI();
                    },
                  );
                },
              )),
              const Gap(defaultPadding),
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productLowStockCtrl,
                  labelText: 'Low Stock Alert Threshold',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                ),
              ),
            ],
          ),
          
          const Gap(defaultPadding * 2),
          _sectionHeader('Shipping Information'),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productWeightCtrl,
                  labelText: 'Weight (grams)',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                ),
              ),
              const Gap(defaultPadding),
              Expanded(child: Container()),
            ],
          ),
          const Gap(defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productLengthCtrl,
                  labelText: 'Length (cm)',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                ),
              ),
              const Gap(defaultPadding),
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productWidthCtrl,
                  labelText: 'Width (cm)',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                ),
              ),
              const Gap(defaultPadding),
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productHeightCtrl,
                  labelText: 'Height (cm)',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                ),
              ),
            ],
          ),
          
          const Gap(defaultPadding * 2),
          _sectionHeader('Product Status'),
          Consumer<DashBoardProvider>(
            builder: (context, dashProvider, child) {
              return SwitchListTile(
                title: const Text('Active Product'),
                subtitle: const Text('Product visible to customers'),
                value: dashProvider.isProductActive,
                activeColor: Colors.green,
                onChanged: (val) {
                  dashProvider.isProductActive = val;
                  dashProvider.updateUI();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Tab 4: Details
  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Additional Details'),
          CustomTextField(
            controller: context.dashBoardProvider.productWarrantyCtrl,
            labelText: 'Warranty Information',
            onSave: (val) {},
          ),
          const Gap(defaultPadding),
          CustomTextField(
            controller: context.dashBoardProvider.productTagsCtrl,
            labelText: 'Tags (comma separated)',
            onSave: (val) {},
          ),
          const Gap(defaultPadding),
          
          _sectionHeader('Specifications'),
          Consumer<DashBoardProvider>(
            builder: (context, dashProvider, child) {
              return Column(
                children: [
                  ...dashProvider.productSpecs.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Key',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: entry.value['key']),
                              onChanged: (val) {
                                dashProvider.productSpecs[idx]['key'] = val;
                              },
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Value',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: entry.value['value']),
                              onChanged: (val) {
                                dashProvider.productSpecs[idx]['value'] = val;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              dashProvider.productSpecs.removeAt(idx);
                              dashProvider.updateUI();
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const Gap(8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: secondaryColor),
                    onPressed: () {
                      dashProvider.productSpecs.add({'key': '', 'value': ''});
                      dashProvider.updateUI();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Specification'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Tab 5: Media
  Widget _buildMediaTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Product Images'),
          const Text(
            'Upload up to 5 product images. First image will be the main product image.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Gap(defaultPadding),
          Wrap(
            spacing: defaultPadding,
            runSpacing: defaultPadding,
            children: [
              Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return ProductImageCard(
                    labelText: 'Main Image *',
                    imageFile: dashProvider.selectedMainImage,
                    imageUrlForUpdateImage: widget.product?.images.safeElementAt(0)?.url,
                    onTap: () => dashProvider.pickImage(imageCardNumber: 1),
                    onRemoveImage: () {
                      dashProvider.selectedMainImage = null;
                      dashProvider.updateUI();
                    },
                  );
                },
              ),
              Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return ProductImageCard(
                    labelText: 'Image 2',
                    imageFile: dashProvider.selectedSecondImage,
                    imageUrlForUpdateImage: widget.product?.images.safeElementAt(1)?.url,
                    onTap: () => dashProvider.pickImage(imageCardNumber: 2),
                    onRemoveImage: () {
                      dashProvider.selectedSecondImage = null;
                      dashProvider.updateUI();
                    },
                  );
                },
              ),
              Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return ProductImageCard(
                    labelText: 'Image 3',
                    imageFile: dashProvider.selectedThirdImage,
                    imageUrlForUpdateImage: widget.product?.images.safeElementAt(2)?.url,
                    onTap: () => dashProvider.pickImage(imageCardNumber: 3),
                    onRemoveImage: () {
                      dashProvider.selectedThirdImage = null;
                      dashProvider.updateUI();
                    },
                  );
                },
              ),
              Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return ProductImageCard(
                    labelText: 'Image 4',
                    imageFile: dashProvider.selectedFourthImage,
                    imageUrlForUpdateImage: widget.product?.images.safeElementAt(3)?.url,
                    onTap: () => dashProvider.pickImage(imageCardNumber: 4),
                    onRemoveImage: () {
                      dashProvider.selectedFourthImage = null;
                      dashProvider.updateUI();
                    },
                  );
                },
              ),
              Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  return ProductImageCard(
                    labelText: 'Image 5',
                    imageFile: dashProvider.selectedFifthImage,
                    imageUrlForUpdateImage: widget.product?.images.safeElementAt(4)?.url,
                    onTap: () => dashProvider.pickImage(imageCardNumber: 5),
                    onRemoveImage: () {
                      dashProvider.selectedFifthImage = null;
                      dashProvider.updateUI();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tab 6: SEO
  Widget _buildSeoTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Search Engine Optimization'),
          const Text(
            'Optimize how your product appears in search engines',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Gap(defaultPadding),
          CustomTextField(
            controller: context.dashBoardProvider.productMetaTitleCtrl,
            labelText: 'Meta Title',
            onSave: (val) {},
          ),
          const Gap(defaultPadding),
          CustomTextField(
            controller: context.dashBoardProvider.productMetaDescCtrl,
            labelText: 'Meta Description',
            lineNumber: 3,
            onSave: (val) {},
          ),
          const Gap(defaultPadding * 2),
          
          // SEO Preview
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Search Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                const Gap(8),
                Consumer<DashBoardProvider>(
                  builder: (context, dashProvider, child) {
                    final title = dashProvider.productMetaTitleCtrl.text.isNotEmpty
                        ? dashProvider.productMetaTitleCtrl.text
                        : dashProvider.productNameCtrl.text;
                    final desc = dashProvider.productMetaDescCtrl.text.isNotEmpty
                        ? dashProvider.productMetaDescCtrl.text
                        : dashProvider.productDescCtrl.text;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isNotEmpty ? title : 'Product Title',
                          style: const TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                        Text(
                          'www.asbrand.com/product/${dashProvider.productSkuCtrl.text.isNotEmpty ? dashProvider.productSkuCtrl.text : "..."}',
                          style: const TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        Text(
                          desc.isNotEmpty ? (desc.length > 150 ? '${desc.substring(0, 150)}...' : desc) : 'Product description...',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }
}

// How to show the popup
void showAddProductForm(BuildContext context, Product? product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text(
            product != null ? 'EDIT PRODUCT' : 'ADD PRODUCT',
            style: const TextStyle(color: primaryColor),
          ),
        ),
        content: ProductSubmitForm(product: product),
      );
    },
  );
}

extension SafeList<T> on List<T>? {
  T? safeElementAt(int index) {
    if (this == null || index < 0 || index >= this!.length) {
      return null;
    }
    return this![index];
  }
}
