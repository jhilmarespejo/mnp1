// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:mnp1/config/models/establishment_types_model.dart';
// import 'package:mnp1/config/models/establishments_model.dart';
// import 'package:mnp1/config/app_theme.dart';
import 'package:mnp1/config/providers/establishment_types_provider.dart';
import 'package:mnp1/screens/list_establishments_screen.dart';
import 'package:provider/provider.dart';
import '/app_constants.dart';

class EstablishmentTypesScreen extends StatefulWidget {
  const EstablishmentTypesScreen({super.key});

  @override
  State<EstablishmentTypesScreen> createState() => _EstablishmentsScreenState();
}

class _EstablishmentsScreenState extends State<EstablishmentTypesScreen> {
  final typeEstablishments = Provider.of<EstablishmentTypesProvider>(
      AppConstants.globalNavKey.currentContext!);

  @override
  void initState() {
    typeEstablishments.loadTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de establecimiento'),
        elevation: 10,
        // backgroundColor:AppTheme(selectedColor:3),
      ),
      body: const _EstablishmentsWidget(),
    );
  }
}

class _EstablishmentsWidget extends StatelessWidget {
  const _EstablishmentsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EstablishmentTypesProvider>(
      builder: (context, typeEstablishments, _) {
        return typeEstablishments.isLoading
            ? const Center(child: CircularProgressIndicator())
            : typeEstablishments.types.isEmpty
              ? const Center(
                  child: Text('sin datos', style: TextStyle(fontSize: 18)))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: typeEstablishments.types.length,
                    itemBuilder: (context, index) {
                      final type = typeEstablishments.types[index];
                      return OutlinedButton.icon(
                        label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(type.tesTipo),
                        ),
                        icon: const Icon(Icons.arrow_forward_ios_outlined),
                        onPressed: () {
                          _navigateEstablecimientos(context, type );
                        },
                      );
                      
                    },
                  ),
                );
      },
    );
  }

  void _navigateEstablecimientos(BuildContext context, EstablishmentTypesModel type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListEstablismentsScreen( type: type)),
    );
    // setState(() {});
  }
}
