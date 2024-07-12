class Company {
  String? companyName;
  String? companyWebsite;
  String? companyEmail;
  String? companyAddress;
  String? companyTel1;
  String? companyTel2;

  Company(
      {this.companyName,
      this.companyWebsite,
      this.companyEmail,
      this.companyAddress,
      this.companyTel1,
      this.companyTel2});

  Company.fromJson(Map<String, dynamic> json) {
    companyName = json['company_name'];
    companyWebsite = json['company_website'];
    companyEmail = json['company_email'];
    companyAddress = json['company_address'];
    companyTel1 = json['company_tel1'];
    companyTel2 = json['company_tel2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_name'] = this.companyName;
    data['company_website'] = this.companyWebsite;
    data['company_email'] = this.companyEmail;
    data['company_address'] = this.companyAddress;
    data['company_tel1'] = this.companyTel1;
    data['company_tel2'] = this.companyTel2;
    return data;
  }
}
