/// Enhanced Product model for admin panel
class Product {
  String? sId;
  String? name;
  String? description;
  String? sku;
  
  // Pricing
  double? price;
  double? offerPrice;
  bool? emiEligible;
  
  // Inventory
  int? quantity;
  String? stockStatus; // in_stock, out_of_stock, low_stock, pre_order
  int? lowStockThreshold;
  
  // Shipping
  double? weight;
  ProductDimensions? dimensions;
  
  // Categories
  ProRef? proCategoryId;
  ProRef? proSubCategoryId;
  ProRef? proBrandId;
  ProTypeRef? proVariantTypeId;
  List<String>? proVariantId;
  
  // Details
  List<String>? tags;
  List<ProductSpec>? specifications;
  String? warranty;
  
  // Flags
  bool? featured;
  bool? isActive;
  
  // SEO
  String? metaTitle;
  String? metaDescription;
  
  // Clothing-specific fields
  String? gender;         // Men, Women, Unisex, Boys, Girls
  String? material;       // Cotton, Polyester, Silk, etc.
  String? fit;            // Regular, Slim, Relaxed, Oversized
  String? pattern;        // Solid, Striped, Printed, Checked
  String? sleeveLength;   // Full, Half, Sleeveless, 3-Quarter
  String? neckline;       // Round, V-Neck, Collar, Mandarin
  String? occasion;       // Casual, Formal, Party, Sports
  String? careInstructions; // Machine Wash, Dry Clean, Hand Wash
  
  // Media
  List<Images>? images;
  
  String? createdAt;
  String? updatedAt;
  int? iV;

  Product({
    this.sId,
    this.name,
    this.description,
    this.sku,
    this.price,
    this.offerPrice,
    this.emiEligible,
    this.quantity,
    this.stockStatus,
    this.lowStockThreshold,
    this.weight,
    this.dimensions,
    this.proCategoryId,
    this.proSubCategoryId,
    this.proBrandId,
    this.proVariantTypeId,
    this.proVariantId,
    this.tags,
    this.specifications,
    this.warranty,
    this.featured,
    this.isActive,
    this.metaTitle,
    this.metaDescription,
    // Clothing fields
    this.gender,
    this.material,
    this.fit,
    this.pattern,
    this.sleeveLength,
    this.neckline,
    this.occasion,
    this.careInstructions,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    sku = json['sku'];
    price = json['price']?.toDouble();
    offerPrice = json['offerPrice']?.toDouble();
    emiEligible = json['emiEligible'] ?? true;
    quantity = json['quantity'];
    stockStatus = json['stockStatus'] ?? 'in_stock';
    lowStockThreshold = json['lowStockThreshold'] ?? 10;
    weight = json['weight']?.toDouble();
    dimensions = json['dimensions'] != null
        ? ProductDimensions.fromJson(json['dimensions'])
        : null;
    proCategoryId = json['proCategoryId'] != null
        ? ProRef.fromJson(json['proCategoryId'])
        : null;
    proSubCategoryId = json['proSubCategoryId'] != null
        ? ProRef.fromJson(json['proSubCategoryId'])
        : null;
    proBrandId = json['proBrandId'] != null
        ? ProRef.fromJson(json['proBrandId'])
        : null;
    proVariantTypeId = json['proVariantTypeId'] != null
        ? ProTypeRef.fromJson(json['proVariantTypeId'])
        : null;
    if (json['proVariantId'] != null) {
      proVariantId = List<String>.from(json['proVariantId']);
    }
    if (json['tags'] != null) {
      tags = List<String>.from(json['tags']);
    }
    if (json['specifications'] != null) {
      specifications = (json['specifications'] as List)
          .map((e) => ProductSpec.fromJson(e))
          .toList();
    }
    warranty = json['warranty'];
    featured = json['featured'] ?? false;
    isActive = json['isActive'] ?? true;
    metaTitle = json['metaTitle'];
    metaDescription = json['metaDescription'];
    // Clothing fields
    gender = json['gender'];
    material = json['material'];
    fit = json['fit'];
    pattern = json['pattern'];
    sleeveLength = json['sleeveLength'];
    neckline = json['neckline'];
    occasion = json['occasion'];
    careInstructions = json['careInstructions'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['sku'] = sku;
    data['price'] = price;
    data['offerPrice'] = offerPrice;
    data['emiEligible'] = emiEligible;
    data['quantity'] = quantity;
    data['stockStatus'] = stockStatus;
    data['lowStockThreshold'] = lowStockThreshold;
    data['weight'] = weight;
    if (dimensions != null) data['dimensions'] = dimensions!.toJson();
    if (proCategoryId != null) data['proCategoryId'] = proCategoryId!.toJson();
    if (proSubCategoryId != null) data['proSubCategoryId'] = proSubCategoryId!.toJson();
    if (proBrandId != null) data['proBrandId'] = proBrandId!.toJson();
    if (proVariantTypeId != null) data['proVariantTypeId'] = proVariantTypeId!.toJson();
    data['proVariantId'] = proVariantId;
    data['tags'] = tags;
    if (specifications != null) {
      data['specifications'] = specifications!.map((e) => e.toJson()).toList();
    }
    data['warranty'] = warranty;
    data['featured'] = featured;
    data['isActive'] = isActive;
    data['metaTitle'] = metaTitle;
    data['metaDescription'] = metaDescription;
    // Clothing fields
    data['gender'] = gender;
    data['material'] = material;
    data['fit'] = fit;
    data['pattern'] = pattern;
    data['sleeveLength'] = sleeveLength;
    data['neckline'] = neckline;
    data['occasion'] = occasion;
    data['careInstructions'] = careInstructions;
    if (images != null) data['images'] = images!.map((v) => v.toJson()).toList();
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }

  // Helper getters
  int get discountPercent {
    if (offerPrice != null && price != null && price! > offerPrice!) {
      return ((price! - offerPrice!) / price! * 100).round();
    }
    return 0;
  }

  String get stockStatusLabel {
    switch (stockStatus) {
      case 'in_stock': return 'In Stock';
      case 'out_of_stock': return 'Out of Stock';
      case 'low_stock': return 'Low Stock';
      case 'pre_order': return 'Pre-Order';
      default: return 'Unknown';
    }
  }
}

class ProductDimensions {
  double? length;
  double? width;
  double? height;

  ProductDimensions({this.length, this.width, this.height});

  ProductDimensions.fromJson(Map<String, dynamic> json) {
    length = json['length']?.toDouble() ?? 0;
    width = json['width']?.toDouble() ?? 0;
    height = json['height']?.toDouble() ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {'length': length, 'width': width, 'height': height};
  }

  String get displayString => '${length ?? 0} × ${width ?? 0} × ${height ?? 0} cm';
}

class ProductSpec {
  String? key;
  String? value;

  ProductSpec({this.key, this.value});

  ProductSpec.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value};
  }
}

class ProRef {
  String? sId;
  String? name;

  ProRef({this.sId, this.name});

  ProRef.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {'_id': sId, 'name': name};
  }
}

class ProTypeRef {
  String? sId;
  String? type;

  ProTypeRef({this.sId, this.type});

  ProTypeRef.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    return {'_id': sId, 'type': type};
  }
}

class Images {
  int? image;
  String? url;
  String? sId;

  Images({this.image, this.url, this.sId});

  Images.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    url = json['url'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    return {'image': image, 'url': url, '_id': sId};
  }
}