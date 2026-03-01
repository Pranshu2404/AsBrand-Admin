class VariantType {
  String? name;
  String? type;
  String? sId;
  String? createdAt;
  String? updatedAt;

  VariantType(
      {this.name,
        this.type,
        this.sId,
        this.createdAt,
        this.updatedAt,
        });

  VariantType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    // Handle 'type' being either a plain String or a populated object
    if (json['type'] is String) {
      type = json['type'];
    } else if (json['type'] is Map) {
      type = json['type']['name'] ?? json['type']['_id']?.toString();
    }
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}