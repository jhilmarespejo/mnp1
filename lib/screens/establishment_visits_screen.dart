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

  final TextEditingController establishmentNameController =
      TextEditingController();
  late int estIdlController;
  @override
  void initState() {
    estIdlController = widget.establishment.estId!;
    establishmentNameController.text = widget.establishment.estNombre!;
    visitsProvider.loadVisits(estIdlController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(establishmentNameController.text),
        elevation: 10,
        // backgroundColor:AppTheme(selectedColor:3),
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
            : visitsProvider.visits.isEmpty
                ? const Center(
                    child: Text('Sin datos!', style: TextStyle(fontSize: 18)))
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: visitsProvider.visits.length,
                      itemBuilder: (context, index) {
                        final visit = visitsProvider.visits[index];
                        return OutlinedButton.icon(
                          label: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(visit.visTipo),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                          onPressed: () {
                            // _navigateEstablecimientos(context, type );
                          },
                        );
                      },
                    ),
                  );
      },
    );
  }
}
