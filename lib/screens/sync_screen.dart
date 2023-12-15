import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización de datos'),
      ),
      body: const _ButtonsView(),
    );
  }
}

class _ButtonsView extends StatefulWidget {
  const _ButtonsView();

  @override
  State<_ButtonsView> createState() => _ButtonsViewState();
}

class _ButtonsViewState extends State<_ButtonsView> {
  bool isLoading = false;

  final tipoEst = DatabaseHelper();
  // final establecimientos = EstablishmentsHelper();

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
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
          FilledButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Consulta X'),
            onPressed: () {
              _queryX();
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
          const SizedBox(
            height: 30,
          ),
          FilledButton.icon(
            icon: const Icon(Icons.get_app_sharp),
            label: const Text('LOGIN'),
            onPressed: () {
              _navigateLogin(context);
            },
          ),
        ],
      ),
    );
  }
  
   void _navigateLogin(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
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
    //await establecimientos.loadFromApiAndSaveEstablishments();
  }

  void _getdata() async {
    await tipoEst.getData();
  }

  void _queryX() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    String tesTipo = 'Centro Penitenciario';
    List<EstablishmentsModel> resultados = await dbHelper.queryx( tesTipo );
    for (var resultado in resultados) {
      print(
          'Tipo: ${resultado.tesTipo},nombre: ${resultado.estNombre},direccion: ${resultado.estDireccion} ');
    }
  }

  void _deletedata() async {
    await tipoEst.deleteData();
  }
}
