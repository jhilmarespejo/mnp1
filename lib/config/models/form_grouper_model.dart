class FormGrouperModel {
  final String? agfId;
  final int fkFrmId;
  final int fkUserId;
  final int agfCopia;

  // UserModel({this.id, required this.name, required this.email, required this.desc});
  // CONSTRUCTOR
  FormGrouperModel({
    this.agfId,
    required this.fkFrmId,
    required this.fkUserId,
    required this.agfCopia,
  });

  factory FormGrouperModel.fromMap(Map<String, dynamic> map) {
    return FormGrouperModel(
      agfId: map['AGF_id'],
      fkFrmId: map['FK_FRM_id'],
      fkUserId: map['FK_USER_id'],
      agfCopia: map['AGF_copia'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'AGF_id': agfId,
      'FK_FRM_id': fkFrmId,
      'FK_USER_id': fkUserId,
      'AGF_copia': agfCopia,
    };
  }
}
