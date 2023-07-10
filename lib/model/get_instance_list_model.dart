class GetInstanceListModel {
  int? idInstance;
  String? name;
  String? typeInstance;
  String? typeAccount;
  String? partnerUserUiid;
  String? timeCreated;
  String? timeDeleted;
  String? apiTokenInstance;
  bool? deleted;
  String? tariff;
  String? expirationDate;
  bool? isExpired;

  GetInstanceListModel(
      {this.idInstance,
      this.name,
      this.typeInstance,
      this.typeAccount,
      this.partnerUserUiid,
      this.timeCreated,
      this.timeDeleted,
      this.apiTokenInstance,
      this.deleted,
      this.tariff,
      this.expirationDate,
      this.isExpired});

  GetInstanceListModel.fromJson(Map<String, dynamic> json) {
    idInstance = json['idInstance'];
    name = json['name'];
    typeInstance = json['typeInstance'];
    typeAccount = json['typeAccount'];
    partnerUserUiid = json['partnerUserUiid'];
    timeCreated = json['timeCreated'];
    timeDeleted = json['timeDeleted'];
    apiTokenInstance = json['apiTokenInstance'];
    deleted = json['deleted'];
    tariff = json['tariff'];
    expirationDate = json['expirationDate'];
    isExpired = json['isExpired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idInstance'] = this.idInstance;
    data['name'] = this.name;
    data['typeInstance'] = this.typeInstance;
    data['typeAccount'] = this.typeAccount;
    data['partnerUserUiid'] = this.partnerUserUiid;
    data['timeCreated'] = this.timeCreated;
    data['timeDeleted'] = this.timeDeleted;
    data['apiTokenInstance'] = this.apiTokenInstance;
    data['deleted'] = this.deleted;
    data['tariff'] = this.tariff;
    data['expirationDate'] = this.expirationDate;
    data['isExpired'] = this.isExpired;
    return data;
  }
}
