class QuestionnarieModel {
  final int? id;
  final int rbfId;
  final int fkFrmId;
  final int fkBcpId;
  final int bcpId;
  final int rbfOrden;
  final int? rbfEstado;
  final int catId;
  final int catSubcatId;
  final String bcpPregunta;
  final String bcpTipoRespuesta;
  final String? bcpOpciones;
  final String? bcpComplemento;
  final String catSubcategoria;
  final String catCategoria;
  final String frmTitulo;

  // UserModel({this.id, required this.name, required this.email, required this.desc});
  // CONSTRUCTOR
  QuestionnarieModel({
    this.id,
    required this.rbfId,
    required this.fkFrmId,
    required this.fkBcpId,
    required this.bcpId,
    required this.rbfOrden,
    this.rbfEstado,
    required this.catId,
    required this.catSubcatId,
    required this.bcpPregunta,
    required this.bcpTipoRespuesta,
    this.bcpOpciones,
    this.bcpComplemento,
    required this.catSubcategoria,
    required this.catCategoria,
    required this.frmTitulo,

  });

  factory QuestionnarieModel.fromMap(Map<String, dynamic> map) {
    return QuestionnarieModel(
      id: map['id'],
      rbfId: map['RBF_id'],
      fkFrmId: map['FK_FRM_id'],
      fkBcpId: map['FK_BCP_id'],
      bcpId: map['BCP_id'],
      rbfOrden: map['RBF_orden'],
      rbfEstado: map['RBF_estado'],
      catId: map['CAT_id'],
      catSubcatId: map['CAT_subcat_id'],
      bcpPregunta: map['BCP_pregunta'],
      bcpTipoRespuesta: map['BCP_tipoRespuesta'],
      bcpOpciones: map['BCP_opciones'],
      bcpComplemento: map['BCP_complemento'],
      catSubcategoria: map['CAT_subcategoria'],
      catCategoria: map['CAT_categoria'],
      frmTitulo: map['FRM_titulo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'RBF_id': rbfId,
      'FK_FRM_id': fkFrmId,
      'FK_BCP_id': fkBcpId,
      'BCP_id': bcpId,
      'RBF_orden': rbfOrden,
      'RBF_estado': rbfEstado,
      'CAT_id': catId,
      'CAT_subcat_id': catSubcatId,
      'BCP_pregunta': bcpPregunta,
      'BCP_tipoRespuesta': bcpTipoRespuesta,
      'BCP_opciones': bcpOpciones,
      'BCP_complemento': bcpComplemento,
      'CAT_subcategoria': catSubcategoria,
      'CAT_categoria': catCategoria,
      'FRM_titulo': frmTitulo,
    };
  }
}
