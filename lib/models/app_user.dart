/// User model for admin panel
class AppUser {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? createdAt;
  String? updatedAt;

  AppUser({
    this.sId,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  AppUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    role = json['role'] ?? 'user';
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isAdmin => role == 'admin';
}
