class EstablishmentsModel {
  final int? id;
  final String? estNombre;
  final String? tesTipo;
  final int? estId;
  final String? estDireccion;
  final String? estDepartamento;
  final String? estProvincia;
  final String? estMunicipio;

  // UserModel({this.id, required this.name, required this.email, required this.desc});
  // CONSTRUCTOR
  EstablishmentsModel({
    this.id,
    this.estNombre,
    this.tesTipo,
    this.estId,
    this.estDireccion,
    this.estDepartamento,
    this.estProvincia,
    this.estMunicipio,
  });

  factory EstablishmentsModel.fromMap(Map<String, dynamic> map) {
    return EstablishmentsModel(
        id: map["id"],
        estNombre: map["EST_nombre"],
        tesTipo: map["TES_tipo"],
        estId: map["EST_id"],
        estDireccion: map["EST_direccion"],
        estDepartamento: map["EST_departamento"],
        estProvincia: map["EST_provincia"],
        estMunicipio: map["EST_municipio"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "EST_nombre": estNombre,
      "TES_tipo": tesTipo,
      "EST_id": estId,
      "EST_direccion": estDireccion,
      "EST_departamento": estDepartamento,
      "EST_provincia": estProvincia,
      "EST_municipio": estMunicipio,
    };
  }
}
