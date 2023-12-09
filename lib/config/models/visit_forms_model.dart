class VisitFormsModel {
  final int? id;
  final int frmId;
  final int visId;
  final int estId;
  final String? frmTitulo;
  final String? frmFecha;
  final String? visTitulo;
  final String? visFechas;
  final String visNumero;
  final String visTipo;
  final String estNombre;

  // UserModel({this.id, required this.name, required this.email, required this.desc});
  // CONSTRUCTOR
  VisitFormsModel({
    this.id,
    required this.frmId,
    required this.visId,
    required this.estId,
    this.frmTitulo,
    this.frmFecha,
    this.visTitulo,
    this.visFechas,
    required this.visNumero,
    required this.visTipo,
    required this.estNombre,
  });

  factory VisitFormsModel.fromMap(Map<String, dynamic> map) {
    return VisitFormsModel(
      id: map['id'],
      frmId: map["FRM_id"],
      visId: map["VIS_id"],
      estId: map["EST_id"],
      frmTitulo: map["FRM_titulo"],
      frmFecha: map["FRM_fecha"],
      visTitulo: map["VIS_titulo"],
      visFechas: map["VIS_fechas"],
      visNumero: map["VIS_numero"],
      visTipo: map["VIS_tipo"],
      estNombre: map["EST_nombre"],
      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "FRM_id": frmId,
      "VIS_id": visId,
      "EST_id": estId,
      "FRM_titulo": frmTitulo,
      "FRM_fecha": frmFecha,
      "VIS_titulo": visTitulo,
      "VIS_fechas": visFechas,
      "VIS_numero": visNumero,
      "VIS_tipo": visTipo,
      "EST_nombre": estNombre,
    };
  }
}
