import 'package:flutter/material.dart';
import 'package:mnp1/config/helpers/establishments_helper.dart';
import 'package:mnp1/config/models/establishment_types_model.dart';

class EstablishmentTypesProvider with ChangeNotifier {
  bool isLoading = false;
  List<EstablishmentTypesModel> _types = [];
  final EstablishmentTypesHelper _databaseHelper = EstablishmentTypesHelper();

  List<EstablishmentTypesModel> get types => _types;

  Future<void> loadTypes() async {
    isLoading = true;
    _types = await _databaseHelper.getData();
    isLoading = false;
    notifyListeners();
  }

}
