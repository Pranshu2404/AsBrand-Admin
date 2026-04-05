class Setting {
  String? sId;
  double? referralRewardPercent;
  double? firstOrderRewardPercent;
  double? deliveryChargeWithin1km;
  double? deliveryChargePerKm2to5;
  double? deliveryChargeOver5km;
  double? handlingCharge;
  String? createdAt;
  String? updatedAt;

  Setting({
    this.sId,
    this.referralRewardPercent,
    this.firstOrderRewardPercent,
    this.deliveryChargeWithin1km,
    this.deliveryChargePerKm2to5,
    this.deliveryChargeOver5km,
    this.handlingCharge,
    this.createdAt,
    this.updatedAt,
  });

  Setting.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    referralRewardPercent = json['referralRewardPercent']?.toDouble();
    firstOrderRewardPercent = json['firstOrderRewardPercent']?.toDouble();
    deliveryChargeWithin1km = json['deliveryChargeWithin1km']?.toDouble();
    deliveryChargePerKm2to5 = json['deliveryChargePerKm2to5']?.toDouble();
    deliveryChargeOver5km = json['deliveryChargeOver5km']?.toDouble();
    handlingCharge = json['handlingCharge']?.toDouble();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['referralRewardPercent'] = referralRewardPercent;
    data['firstOrderRewardPercent'] = firstOrderRewardPercent;
    data['deliveryChargeWithin1km'] = deliveryChargeWithin1km;
    data['deliveryChargePerKm2to5'] = deliveryChargePerKm2to5;
    data['deliveryChargeOver5km'] = deliveryChargeOver5km;
    data['handlingCharge'] = handlingCharge;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
