import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';

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

  final TextEditingController tesTipoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  late int tesIdlController;

  @override
  void initState() {
    super.initState();
    tesTipoController.text = widget.type.tesTipo;
    // nameController.text = widget.type.name;
    tesIdlController = widget.type.tesId;
    estabsProvider.loadEstablishments(tesIdlController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tesTipoController.text),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              onChanged: (value) {
                estabsProvider.filterEstablishments(value, tesIdlController);
              },
              decoration: const InputDecoration(
                hintText: 'Buscar...',
              ),
            ),
          ),
          Consumer<EstablishmentTypesProvider>(
            builder: (context, estabsProvider, _) {
              return estabsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : estabsProvider.estabs.isEmpty
                      ? const Center(
                          child: Text(
                            "SIN DATOS!",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: ListView.builder(
                              itemCount: estabsProvider.estabs.length,
                              itemBuilder: (context, index) {
                                final establishment =
                                    estabsProvider.estabs[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _navigateVisits(context, establishment);
                                    },
                                    icon: const Icon(
                                        Icons.arrow_forward_ios_outlined),
                                    label: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          establishment.estNombre ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          establishment.estDepartamento ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 101, 100, 100),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
            },
          ),
        ],
      ),
    );
  }

  void _navigateVisits(
      BuildContext context, EstablishmentsModel establishment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              EstablishmentVisitsScreen(establishment: establishment)),
    );
    // setState(() {});
  }
}
