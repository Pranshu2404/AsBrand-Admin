/// UserKyc model for admin panel
class UserKyc {
  String? sId;
  UserRef? userId;
  String? panNumber;
  String? aadhaarNumber;
  String? dateOfBirth;
  String? address;
  String? employmentType;
  double? monthlyIncome;
  String? verificationStatus; // 'not_submitted', 'under_review', 'verified', 'rejected'
  double? creditLimit;
  int? creditScore;
  String? rejectionReason;
  String? verifiedAt;
  String? createdAt;
  String? updatedAt;

  UserKyc({
    this.sId,
    this.userId,
    this.panNumber,
    this.aadhaarNumber,
    this.dateOfBirth,
    this.address,
    this.employmentType,
    this.monthlyIncome,
    this.verificationStatus,
    this.creditLimit,
    this.creditScore,
    this.rejectionReason,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  UserKyc.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null ? UserRef.fromJson(json['userId']) : null;
    panNumber = json['panNumber'];
    aadhaarNumber = json['aadhaarNumber'];
    dateOfBirth = json['dateOfBirth'];
    address = json['address'];
    employmentType = json['employmentType'];
    monthlyIncome = (json['monthlyIncome'] ?? 0).toDouble();
    verificationStatus = json['verificationStatus'] ?? 'not_submitted';
    creditLimit = (json['creditLimit'] ?? 0).toDouble();
    creditScore = json['creditScore'];
    rejectionReason = json['rejectionReason'];
    verifiedAt = json['verifiedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sId != null) data['_id'] = sId;
    data['panNumber'] = panNumber;
    data['aadhaarNumber'] = aadhaarNumber;
    data['dateOfBirth'] = dateOfBirth;
    data['address'] = address;
    data['employmentType'] = employmentType;
    data['monthlyIncome'] = monthlyIncome;
    data['verificationStatus'] = verificationStatus;
    data['creditLimit'] = creditLimit;
    data['creditScore'] = creditScore;
    data['rejectionReason'] = rejectionReason;
    return data;
  }

  bool get isPending => verificationStatus == 'under_review';
  bool get isVerified => verificationStatus == 'verified';
  bool get isRejected => verificationStatus == 'rejected';
  
  String get maskedPan => panNumber != null && panNumber!.length >= 4 
      ? '****${panNumber!.substring(panNumber!.length - 4)}' 
      : '****';
      
  String get maskedAadhaar => aadhaarNumber != null && aadhaarNumber!.length >= 4
      ? '****${aadhaarNumber!.substring(aadhaarNumber!.length - 4)}'
      : '****';
}

class UserRef {
  String? sId;
  String? name;
  String? email;
  String? phone;

  UserRef({this.sId, this.name, this.email, this.phone});

  UserRef.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
