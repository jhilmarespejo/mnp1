class AnswersModel {
  final int? id;
  final String resRespuesta; 
  final int fkRbfId;
  final int fkAgfId;
  final int userId;
 
  // CONSTRUCTOR
  AnswersModel({
    this.id,
    required this.resRespuesta,
    required this.fkRbfId,
    required this.fkAgfId,
    required this.userId,
  });

  factory AnswersModel.fromMap(Map<String, dynamic> map) {
    return AnswersModel(
      id: map['id'],
      resRespuesta: map['RES_respuesta'],
      fkRbfId: map['FK_RBF_id'],
      fkAgfId: map['FK_AGF_id'],
      userId: map['USER_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'RES_respuesta': resRespuesta,
      'FK_RBF_id': fkRbfId,
      'FK_AGF_id': fkAgfId,
      'USER_id': userId,
    };
  }
}
