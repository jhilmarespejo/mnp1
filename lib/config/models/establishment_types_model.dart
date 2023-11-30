class EstablishmentTypesModel {
  final int? id;
  final int tesId;
  final String tesTipo;

  // UserModel({this.id, required this.name, required this.email, required this.desc});
  // CONSTRUCTOR
  EstablishmentTypesModel({
    required this.id,
    required this.tesId,
    required this.tesTipo,
  });

  factory EstablishmentTypesModel.fromMap(Map<String, dynamic> map) {
    return EstablishmentTypesModel(
      id: map['id'],
      tesId: map['TES_id'],
      tesTipo: map['TES_tipo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'TES_id': tesId,
      'TES_tipo': tesTipo,
    };
  }
}

