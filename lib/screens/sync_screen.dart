import 'package:flutter/material.dart';
import 'package:mnp1/config/helpers/establishments_helper.dart';
import 'package:mnp1/screens/establishment_types_screen.dart';

class SyncScreen extends StatelessWidget {
  SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización de datos'),
      ),
      body: _ButtonsView(),
    );
  }
}

class _ButtonsView extends StatelessWidget {
  _ButtonsView();
  final tipoEst = EstablishmentTypesHelper();

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),

        children: [
          FilledButton.icon(
            icon: const Icon(Icons.cloud_sync_outlined),
            label: const Text('Sincronizar datos'),
            onPressed: () {
              _loaddata();
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.get_app_sharp),
            label: const Text('Consultar datos'),
            onPressed: () {
              _getdata();
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Limpiar datos'),
            onPressed: () {
              _deletedata();
            },
          ),
          const SizedBox(
            height: 150,
          ),
          FilledButton.icon(
            icon: const Icon(Icons.get_app_sharp),
            label: const Text('Iniciar'),
            onPressed: () {
              _navigateTipoEstablecimientos(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateTipoEstablecimientos(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EstablishmentTypesScreen()),
    );
    // setState(() {});
  }

  void _loaddata() async {
    await tipoEst.loadFromApiAndSave();
  }

  void _getdata() async {
    await tipoEst.getData();
  }

  void _deletedata() async {
    await tipoEst.deleteData();
  }
}
