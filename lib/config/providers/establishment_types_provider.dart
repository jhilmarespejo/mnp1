import 'package:flutter/material.dart';
import 'package:mnp1/config/helpers/establishment_types_helper.dart';
import 'package:mnp1/config/models/establishment_types_model.dart';
import 'package:mnp1/config/models/establishments_model.dart';

class EstablishmentTypesProvider with ChangeNotifier {
  bool isLoading = false;
  List<EstablishmentTypesModel> _types = [];
  final EstablishmentTypesHelper _databaseHelper = EstablishmentTypesHelper();
  List<EstablishmentTypesModel> get types => _types;

  List<EstablishmentsModel> _estabs = [];
  List<EstablishmentsModel> get estabs => _estabs;

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

  Future<void> filterEstablishments( name, tesId) async {
    isLoading = true;
    _estabs = await _databaseHelper.getEstablishmentByName( name, tesId );
    isLoading = false;
    notifyListeners();
  }

}
