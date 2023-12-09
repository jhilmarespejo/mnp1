import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';

class DatabaseProvider with ChangeNotifier {
  bool isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<EstablishmentTypesModel> _types = [];
  List<EstablishmentTypesModel> get types => _types;

  List<EstablishmentsModel> _estabs = [];
  List<EstablishmentsModel> get estabs => _estabs;

  List<VisitFormsModel> _visitsForms = [];
  List<VisitFormsModel> get visitFroms => _visitsForms;

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
  Future<void> filterEstablishments( name, tesId) async {
    isLoading = true;
    _estabs = await _databaseHelper.getEstablishmentByName( name, tesId );
    isLoading = false;
    notifyListeners();
  }


  Future<void> loadVisits( int estId ) async {
    isLoading = true;
    _visitsForms = await _databaseHelper.getVisitAndForms( estId );
    isLoading = false;
    notifyListeners();
  }

}
