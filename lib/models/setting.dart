class Setting {
  String? sId;
  double? referralRewardPercent;
  double? firstOrderRewardPercent;
  String? createdAt;
  String? updatedAt;

  Setting({
    this.sId,
    this.referralRewardPercent,
    this.firstOrderRewardPercent,
    this.createdAt,
    this.updatedAt,
  });

  Setting.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    referralRewardPercent = json['referralRewardPercent']?.toDouble();
    firstOrderRewardPercent = json['firstOrderRewardPercent']?.toDouble();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['referralRewardPercent'] = referralRewardPercent;
    data['firstOrderRewardPercent'] = firstOrderRewardPercent;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
