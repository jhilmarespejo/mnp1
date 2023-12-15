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
  final estabsProvider = Provider.of<DatabaseProvider>(
      AppConstants.globalNavKey.currentContext!);

  final TextEditingController tesTipoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  late int tesIdController;

  @override
  void initState() {
    super.initState();
    tesTipoController.text = widget.type.tesTipo;
    tesIdController = widget.type.tesId;
    estabsProvider.loadEstablishments(tesIdController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tesTipoController.text),
        elevation: 10,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              onChanged: (value) {
                estabsProvider.filterEstablishments(value, tesIdController);
              },
              decoration: const InputDecoration(
                hintText: 'Buscar...',
              ),
            ),
          ),
          Consumer<DatabaseProvider>(
            builder: (context, estabsProvider, _) {
              return estabsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : estabsProvider.estabs.isEmpty
                      ? const Center(
                          child: Text( "SIN DATOS!", style: TextStyle(fontSize: 18), ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: ListView.separated(
                              separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Theme.of(context).dividerColor),
                              itemCount: estabsProvider.estabs.length,
                              itemBuilder: (context, index) {
                                final establishment =
                                    estabsProvider.estabs[index];

                                return InkWell(
                                  onTap: () {
                                    _navigateVisits(context, establishment);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    color: Theme.of(context).cardColor,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Icon(Icons.account_circle, color: Theme.of(context).iconTheme.color),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text( establishment.estNombre ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              Text(
                                                establishment.estDepartamento ??
                                                    '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios_outlined,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color),
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
              VisitFormsScreen(establishment: establishment)),
    );
    // setState(() {});
  }
}
