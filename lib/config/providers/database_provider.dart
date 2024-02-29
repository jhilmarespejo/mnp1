import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider with ChangeNotifier {
  bool isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<EstablishmentTypesModel> _types = [];
  List<EstablishmentTypesModel> get types => _types;

  List<EstablishmentsModel> _estabs = [];
  List<EstablishmentsModel> get estabs => _estabs;

  List<VisitFormsModel> _visits = [];
  List<VisitFormsModel> get visits => _visits;

  List<VisitFormsModel> _forms = [];
  List<VisitFormsModel> get forms => _forms;

  List<FormGrouperModel> _listForms = [];
  List<FormGrouperModel> get listForms => _listForms;

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> get questions => _questions;

  List<Map<String, dynamic>> _checkAnswer = [];
  List<Map<String, dynamic>> get checkAnswer => _checkAnswer;

  Future<void> loadTypes() async {
    isLoading = true;
    _types = await _databaseHelper.getData();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadEstablishments(tesId) async {
    isLoading = true;
    _estabs = await _databaseHelper.getEstablishmentById(tesId);
    isLoading = false;
    notifyListeners();
  }

// Provider que apunta a la funcion getEstablishmentByName( name, tesId ) establisment_types_helper
  Future<void> filterEstablishments(name, tesId) async {
    isLoading = true;
    _estabs = await _databaseHelper.getEstablishmentByName(name, tesId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadVisitForms(int estId) async {
    isLoading = true;
    _visits = await _databaseHelper.getVisits(estId);
    isLoading = false;
    notifyListeners();
  }

  Future<List<VisitFormsModel>> loadFormsFromVisit(int frmId) async {
    isLoading = true;
    _forms = await _databaseHelper.getFormsFromVisit(frmId);
    isLoading = false;
    notifyListeners();
    return _forms; // Asegúrate de devolver una lista de VisitFormsModel
  }

  Future<List<FormGrouperModel>> loadListForms(int fkFrmId) async {
    isLoading = true;
    _listForms = await _databaseHelper.getListForms(fkFrmId);
    isLoading = false;
    notifyListeners();
    return _listForms;
  }

  
  Future<void> putNewCopyForm(int frmId, BuildContext context) async {
    await _databaseHelper.createNewCopyForm(frmId, context);
    await loadListForms(frmId);
    notifyListeners();
  }

  Future<dynamic> loadFormsQuestionnarie(int frmId, String agfId) async {
    isLoading = true;
    _questions = await _databaseHelper.getQuestionarie(frmId, agfId);
    isLoading = false;
    notifyListeners();
    return _questions;
  }

  Future<dynamic> checkExistingAnswer( int fkRbfId,  String fkAgfId) async {
    try {
      isLoading = true;
      _checkAnswer = await _databaseHelper.getExistingAnswer(fkRbfId, fkAgfId);
      isLoading = false;
      notifyListeners();
      return _checkAnswer;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Error en checkExistingAnswer: $e');
      return null; // Otra forma de manejar errores según tus necesidades
    }
  }
  
  /// Inserta una nueva respuesta en la base de datos y notifica a los oyentes.
  Future<void> putNewAnswer( answer ) async {
    try {
      await _databaseHelper.createNewAnswer(answer);
      notifyListeners();
    } catch (error) {
      print('Error al insertar nueva respuesta: $error');
    }
  }

  Future<void> updateAnswer(dynamic answer, int fkRbfId, String fkAgfId) async {
    try {
      await _databaseHelper.updateActualAnswer(answer, fkRbfId, fkAgfId);
      notifyListeners();
    } catch (error) {
      print('Error al actualizar respuesta: $error');
    }
  }

}

  
// }
