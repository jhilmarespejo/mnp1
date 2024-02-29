class AnswersModel {
  final int? id;
  late final dynamic resRespuesta; 
  final dynamic resComplemento; 
  final int fkRbfId;
  final String fkAgfId;
  final int userId;
  final String deviceId;
 
  // CONSTRUCTOR
  AnswersModel({
    this.id,
    this.resRespuesta,
    this.resComplemento,
    required this.fkRbfId,
    required this.fkAgfId,
    required this.userId,
    required this.deviceId,
  });

  factory AnswersModel.fromMap(Map<String, dynamic> map) {
    return AnswersModel(
      id: map['id'],
      resRespuesta: map['RES_respuesta'],
      resComplemento: map['RES_complemento'],
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
      'RES_complemento': resComplemento,
      'FK_RBF_id': fkRbfId,
      'FK_AGF_id': fkAgfId,
      'USER_id': userId,
      'RES_device_id': deviceId,
    };
  }
}
