class AnswersModel {
  final int? id;
  final dynamic resRespuesta; 
  final int fkRbfId;
  final int fkAgfId;
  final int userId;
  final String deviceId;
 
  // CONSTRUCTOR
  AnswersModel({
    this.id,
     this.resRespuesta,
    required this.fkRbfId,
    required this.fkAgfId,
    required this.userId,
    required this.deviceId,
  });

  factory AnswersModel.fromMap(Map<String, dynamic> map) {
    return AnswersModel(
      id: map['id'],
      resRespuesta: map['RES_respuesta'],
      fkRbfId: map['FK_RBF_id'],
      fkAgfId: map['FK_AGF_id'],
      userId: map['USER_id'],
      deviceId: map['RES_device_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'RES_respuesta': resRespuesta,
      'FK_RBF_id': fkRbfId,
      'FK_AGF_id': fkAgfId,
      'USER_id': userId,
      'RES_device_id': deviceId,
    };
  }
}
