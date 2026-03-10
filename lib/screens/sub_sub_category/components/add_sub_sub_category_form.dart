import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../models/sub_sub_category.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/category_image_card.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/sub_sub_category_provider.dart';

class SubSubCategorySubmitForm extends StatelessWidget {
  final SubSubCategory? subSubCategory;

  const SubSubCategorySubmitForm({super.key, this.subSubCategory});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    context.subSubCategoryProvider.setDataForUpdateSubSubCategory(subSubCategory);
    return SingleChildScrollView(
      child: Form(
        key: context.subSubCategoryProvider.addSubSubCategoryFormKey,
        child: Container(
          padding: EdgeInsets.all(defaultPadding),
          width: size.width * 0.5,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(defaultPadding),
              Consumer<SubSubCategoryProvider>(
                builder: (context, provider, child) {
                  return CategoryImageCard(
                    labelText: "Sub SubCategory",
                    imageFile: provider.selectedImage,
                    imageUrlForUpdateImage: subSubCategory?.image,
                    onTap: () {
                      provider.pickImage();
                    },
                  );
                },
              ),
              Gap(defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: Consumer<SubSubCategoryProvider>(
                      builder: (context, provider, child) {
                        return CustomDropdown<Category>(
                          initialValue: provider.selectedCategory,
                          hintText: provider.selectedCategory?.name ?? 'Select Category',
                          items: context.dataProvider.categories,
                          displayItem: (Category? category) => category?.name ?? '',
                          onChanged: (newValue) {
                            if (newValue != null) {
                              provider.selectedCategory = newValue;
                              provider.selectedSubCategory = null; // Reset sub-category
                              provider.updateUi();
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Consumer<SubSubCategoryProvider>(
                      builder: (context, provider, child) {
                        return CustomDropdown<SubCategory>(
                          initialValue: provider.selectedSubCategory,
                          hintText: provider.selectedSubCategory?.name ?? 'Select Sub Category',
                          items: context.dataProvider.getSubCategoriesForCategory(provider.selectedCategory),
                          displayItem: (SubCategory? subCat) => subCat?.name ?? '',
                          onChanged: (newValue) {
                            if (newValue != null) {
                              provider.selectedSubCategory = newValue;
                              provider.updateUi();
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a sub category';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: context.subSubCategoryProvider.subSubCategoryNameCtrl,
                      labelText: 'Sub SubCategory Name',
                      onSave: (val) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Gap(defaultPadding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: secondaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the popup
                    },
                    child: Text('Cancel'),
                  ),
                  Gap(defaultPadding),
                  Consumer<SubSubCategoryProvider>(
                    builder: (context, provider, child) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                        ),
                        onPressed: provider.isSubmitting ? null : () async {
                          if (provider.addSubSubCategoryFormKey.currentState!.validate()) {
                            provider.addSubSubCategoryFormKey.currentState!.save();
                            await provider.submitSubSubCategory();
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                        child: provider.isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Submit'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddSubSubCategoryForm(BuildContext context, SubSubCategory? subSubCategory) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(child: Text('Add Sub SubCategory'.toUpperCase(), style: TextStyle(color: primaryColor))),
        content: SubSubCategorySubmitForm(subSubCategory: subSubCategory),
      );
    },
  );
}
