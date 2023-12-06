class EstablishmentVisitsModel {
  final int? id;
  final int estId;
  final int visId;
  final String visTipo;
  final String? visTitulo;
  final String estNombre;
  final String visNumero;
  final String visFechas;

  // UserModel({this.id, required this.name, required this.email, required this.desc});
  // CONSTRUCTOR
  EstablishmentVisitsModel({
  this.id,
  required this.estId,
  required this.visId,
  required this.visTipo,
  this.visTitulo,
  required this.estNombre,
  required this.visNumero,
  required this.visFechas,
  });

  factory EstablishmentVisitsModel.fromMap(Map<String, dynamic> map) {
    return EstablishmentVisitsModel(
      id: map['id'],
      estId: map["EST_id"],
      visId: map["VIS_id"],
      visTipo: map["VIS_tipo"],
      visTitulo: map["VIS_titulo"],
      estNombre: map["EST_nombre"],
      visNumero: map["VIS_numero"],
      visFechas: map["VIS_fechas"]
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      "EST_id": estId,
      "VIS_id": visId,
      "VIS_tipo": visTipo,
      "VIS_titulo": visTitulo,
      "EST_nombre": estNombre,
      "VIS_numero": visNumero,
      "VIS_fechas": visFechas,
    };
  }
}
