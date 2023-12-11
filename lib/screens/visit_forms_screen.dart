import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
import 'package:provider/provider.dart';
import '../app_constants.dart';

class VisitFormsScreen extends StatefulWidget {
  final EstablishmentsModel establishment;

  const VisitFormsScreen({super.key, required this.establishment});

  @override
  State<VisitFormsScreen> createState() =>
      _VisitFormsScreenState();
}

class _VisitFormsScreenState extends State<VisitFormsScreen> {
  final visitsProvider = Provider.of<DatabaseProvider>(
      AppConstants.globalNavKey.currentContext!);

  final TextEditingController establishmentNameController = TextEditingController();
  final TextEditingController establishmentTipeController = TextEditingController();
  late int estIdlController;
  @override
  void initState() {
    estIdlController = widget.establishment.estId!;
    establishmentNameController.text = widget.establishment.estNombre!;
    establishmentTipeController.text = widget.establishment.tesTipo!;
    visitsProvider.loadVisitForms( estIdlController );
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
    return Consumer<DatabaseProvider>(
      builder: (context, visitsProvider, _) {
        return visitsProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : visitsProvider.visits.isEmpty
                ? const Center(
                    child: Text('Sin datos!', style: TextStyle(fontSize: 18)))
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: visitsProvider.visits.length,
                      itemBuilder: (context, index) {
                        final visit = visitsProvider.visits[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.all(3),
                          child: ListTile(
                            title: Text(visit.visTipo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(visit.visTitulo ?? ''),
                                Text(visit.visFechas ?? ''),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_outlined),
                            onTap: () async {
                              // Cargar los formularios asociados a esta visita
                              await visitsProvider.loadFormsFromVisit(visit.visId);
                              // Mostrar los formularios en un diálogo o nueva pantalla
                              // ignore: use_build_context_synchronously
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Formularios de la visita ${visit.visId}'),
                                    content: visitsProvider.forms.isEmpty
                                        ? const Text('Esta visita no tiene formularios asociados.')
                                        : ListView.builder(
                                            itemCount: visitsProvider.forms.length,
                                            itemBuilder: (context, index) {
                                              final form = visitsProvider.forms[index];
                                              return ListTile(
                                                title: Text(form.frmTitulo ?? ''),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(form.frmFecha ?? ''),
                                                    // Agrega aquí otros campos del formulario si es necesario
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  );
                                },
                              );
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
