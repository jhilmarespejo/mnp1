import 'package:flutter/material.dart';
import 'package:mnp1/config/helpers/establishments_helper.dart';
import 'package:mnp1/config/models/establishments_model.dart';

class EstablishmentsProvider with ChangeNotifier {
  bool isLoading = false;
  List<EstablishmentsModel> _types = [];
  final EstablishmentsHelper _databaseEstablishmentsHelper = EstablishmentsHelper();

  List<EstablishmentsModel> get types => _types;

  // Future<void> loadEstablishments() async {
  //   isLoading = true;
  //   _types = await _databaseEstablishmentsHelper.getEstablishments();
  //   isLoading = false;
  //   notifyListeners();
  // }
}
