import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
import 'package:provider/provider.dart';
import '../app_constants.dart';

class EstablishmentVisitsScreen extends StatefulWidget {
  final EstablishmentsModel establishment;

  const EstablishmentVisitsScreen({super.key, required this.establishment});

  @override
  State<EstablishmentVisitsScreen> createState() =>
      _EstablishmentVisitsScreenState();
}

class _EstablishmentVisitsScreenState extends State<EstablishmentVisitsScreen> {
  final visitsProvider = Provider.of<EstablishmentTypesProvider>(
      AppConstants.globalNavKey.currentContext!);

  final TextEditingController establishmentNameController = TextEditingController();
  final TextEditingController establishmentTipeController = TextEditingController();
  late int estIdlController;
  @override
  void initState() {
    estIdlController = widget.establishment.estId!;
    establishmentNameController.text = widget.establishment.estNombre!;
    establishmentTipeController.text = widget.establishment.tesTipo!;
    visitsProvider.loadVisits(estIdlController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0), // Ajusta la altura según tus preferencias
        child: AppBar(
          title: Text(establishmentNameController.text),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 1), // Ajusta la altura según tus preferencias
              Text( establishmentTipeController.text,
                style: const TextStyle(fontSize: 16), // Ajusta el estilo según tus preferencias
              ),
            ],
          ),
          elevation: 10,
        ),
      ),
      body: const _VisitsWidget(),
    );
  }
}

class _VisitsWidget extends StatelessWidget {
  const _VisitsWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<EstablishmentTypesProvider>(
      builder: (context, visitsProvider, _) {
        return visitsProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : visitsProvider.visitFroms.isEmpty
                ? const Center(
                    child: Text('Sin datos!', style: TextStyle(fontSize: 18)))
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: visitsProvider.visitFroms.length,
                      itemBuilder: (context, index) {
                        final visit = visitsProvider.visitFroms[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.all(3),
                          child: ListTile(
                            title: Text(visit.visTipo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(visit.visTitulo?? ''),
                                Text(visit.visFechas?? ''),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_outlined),
                            onTap: () {
                              // _navigateEstablecimientos(context, type );
                            },
                          ),
                        );
                      },
                    ),
                  );
      },
    );
  }
}