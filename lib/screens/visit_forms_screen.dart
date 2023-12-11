import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
import 'package:provider/provider.dart';
import '../app_constants.dart';

class VisitFormsScreen extends StatefulWidget {
  final EstablishmentsModel establishment;

  const VisitFormsScreen({Key? key, required this.establishment})
      : super(key: key);

  @override
  State<VisitFormsScreen> createState() => _VisitFormsScreenState();
}

class _VisitFormsScreenState extends State<VisitFormsScreen> {
  late DatabaseProvider visitsProvider;
  final TextEditingController establishmentNameController =
      TextEditingController();
  final TextEditingController establishmentTypeController =
      TextEditingController();
  late int establishmentIdController;

  @override
  void initState() {
    super.initState();
    visitsProvider = Provider.of<DatabaseProvider>(
        AppConstants.globalNavKey.currentContext!);
    establishmentIdController = widget.establishment.estId!;
    establishmentNameController.text = widget.establishment.estNombre!;
    establishmentTypeController.text = widget.establishment.tesTipo!;
    visitsProvider.loadVisitForms(establishmentIdController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          title: Text(establishmentNameController.text),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 1),
              Text(
                establishmentTypeController.text,
                style: const TextStyle(fontSize: 16),
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
                    child: Text('Sin datos!', style: TextStyle(fontSize: 18)),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: visitsProvider.visits.length,
                      itemBuilder: (context, index) {
                        final visit = visitsProvider.visits[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.all(3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExpansionTile(
                                title: ListTile(
                                  title: Text(visit.visTipo),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(visit.visTitulo ?? ''),
                                      Text(visit.visFechas ?? ''),
                                    ],
                                  ),
                                ),
                                onExpansionChanged: (isExpanded) {
                                  if (isExpanded) {
                                    visitsProvider
                                        .loadFormsFromVisit(visit.visId);
                                  }
                                },
                                initiallyExpanded: false,
                                children: [
                                  if (visitsProvider.forms.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Formularios asociados:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          for (final form
                                              in visitsProvider.forms)
                                            ListTile(
                                              title: Text(
                                                form.frmTitulo ?? '',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(form.frmFecha ?? ''),
                                                  // Otros campos del formulario si es necesario
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
      },
    );
  }
}
