/// EmiPlan model for admin panel
class EmiPlan {
  String? sId;
  String? name;
  int? tenure;
  double? interestRate;
  double? processingFee;
  double? minOrderAmount;
  double? maxOrderAmount;
  bool? isActive;
  List<BankPartner>? bankPartners;
  String? createdAt;
  String? updatedAt;

  EmiPlan({
    this.sId,
    this.name,
    this.tenure,
    this.interestRate,
    this.processingFee,
    this.minOrderAmount,
    this.maxOrderAmount,
    this.isActive,
    this.bankPartners,
    this.createdAt,
    this.updatedAt,
  });

  EmiPlan.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    tenure = json['tenure'];
    interestRate = (json['interestRate'] ?? 0).toDouble();
    processingFee = (json['processingFee'] ?? 0).toDouble();
    minOrderAmount = (json['minOrderAmount'] ?? 0).toDouble();
    maxOrderAmount = json['maxOrderAmount'] != null 
        ? (json['maxOrderAmount']).toDouble() 
        : null;
    isActive = json['isActive'] ?? true;
    if (json['bankPartners'] != null) {
      bankPartners = (json['bankPartners'] as List)
          .map((e) => BankPartner.fromJson(e))
          .toList();
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sId != null) data['_id'] = sId;
    data['name'] = name;
    data['tenure'] = tenure;
    data['interestRate'] = interestRate;
    data['processingFee'] = processingFee;
    data['minOrderAmount'] = minOrderAmount;
    if (maxOrderAmount != null) data['maxOrderAmount'] = maxOrderAmount;
    data['isActive'] = isActive;
    if (bankPartners != null) {
      data['bankPartners'] = bankPartners!.map((e) => e.toJson()).toList();
    }
    return data;
  }

  /// Get display name for EMI plan
  String get displayName => '$tenure Month${tenure != 1 ? 's' : ''} @ ${interestRate ?? 0}%';
  
  /// Calculate monthly EMI for given amount
  double calculateEMI(double principal) {
    if (interestRate == 0 || interestRate == null) {
      return principal / (tenure ?? 1);
    }
    final monthlyRate = (interestRate! / 100) / 12;
    final n = tenure ?? 1;
    return (principal * monthlyRate * 
           (double.parse((1 + monthlyRate).toStringAsFixed(10))) / 
           (double.parse((1 + monthlyRate).toStringAsFixed(10)) - 1));
  }
}

class BankPartner {
  String? bankName;
  String? cardType; // 'credit', 'debit', 'both'

  BankPartner({this.bankName, this.cardType});

  BankPartner.fromJson(Map<String, dynamic> json) {
    bankName = json['bankName'];
    cardType = json['cardType'];
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'cardType': cardType,
    };
  }
}
