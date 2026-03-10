import 'category.dart';
import 'sub_category.dart';

class SubSubCategory {
  String? sId;
  String? name;
  Category? categoryId;
  SubCategory? subCategoryId;
  String? image;
  String? createdAt;
  String? updatedAt;

  SubSubCategory({
    this.sId,
    this.name,
    this.categoryId,
    this.subCategoryId,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  SubSubCategory.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    categoryId = json['categoryId'] != null
        ? Category.fromJson(json['categoryId'])
        : null;
    subCategoryId = json['subCategoryId'] != null
        ? SubCategory.fromJson(json['subCategoryId'])
        : null;
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['name'] = name;
    if (categoryId != null) {
      data['categoryId'] = categoryId!.toJson();
    }
    if (subCategoryId != null) {
      data['subCategoryId'] = subCategoryId!.toJson();
    }
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
