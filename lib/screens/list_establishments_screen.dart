import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';
import 'package:provider/provider.dart';

class ListEstablismentsScreen extends StatefulWidget {
  final EstablishmentTypesModel type;
  const ListEstablismentsScreen({super.key, required this.type});

  @override
  State<ListEstablismentsScreen> createState() =>
      _ListEstablismentsScreenState();
}

class _ListEstablismentsScreenState extends State<ListEstablismentsScreen> {
  final estabsProvider = Provider.of<EstablishmentTypesProvider>(
      AppConstants.globalNavKey.currentContext!);

  final tesTipoController = TextEditingController();
  late int tesIdlController = TextEditingController() as int;
  @override
  void initState() {
    super.initState();
    tesTipoController.text = widget.type.tesTipo;
    tesIdlController = widget.type.tesId;
    // int typeId = int.parse(widget.type.tesId.toString());
    // convertir typeIdController.text a un entero cuando sea necesario // int typeId = int.parse(typeIdController.text);
    estabsProvider.loadEstablishments(tesIdlController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tesTipoController.text),
        ),
        body: Consumer<EstablishmentTypesProvider>(
          builder: (context, estabsProvider, _) {
            return estabsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : estabsProvider.types.isEmpty
                    ? const Center(
                        child: Text(
                        "SIN DATOS!",
                        style: TextStyle(fontSize: 18),
                      ))
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.builder(
                          itemCount: estabsProvider.estabs.length,
                          itemBuilder: (context, index) {
                            final establishment = estabsProvider.estabs[index];
                            return OutlinedButton.icon(
                                onPressed: () {
                                  // _navigateEstablecimientos(context, type);
                                },
                                icon: const Icon(Icons.arrow_forward_ios_outlined),
                                label: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      establishment.estNombre ?? '',
                                      style: const TextStyle(
                                        fontSize: 16, // Tamaño de fuente del texto principal
                                      ),
                                    ),
                                    Text(
                                      establishment.estDepartamento ?? '', // Agrega el subtítulo deseado
                                      style: const TextStyle(
                                        fontSize: 12, // Tamaño de fuente del subtítulo
                                        color: Colors.grey, // Color del subtítulo
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            // return Card(
                            //   elevation: 4,
                            //   color: Theme.of(context).primaryColor,
                            //   child: Padding(padding: const EdgeInsets.all(12.0),
                            //   child: ListTile(
                            //     title: Padding(
                            //        padding: const EdgeInsets.only(bottom: 5.0),
                            //        child: Text(
                            //           establishment.estNombre ?? '',
                            //           style: Theme.of(context).textTheme.bodyLarge!.copyWith(    fontSize: 18 
                            //           ),
                            //        ),
                            //     ),
                            //   ),
                            //   ),
                            // );
                          },
                        ),
                      );
          },
        ));
  }
}
