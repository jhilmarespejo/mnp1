import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización de datos'),
      ),
      body: const Center (
        child: _ButtonsView(),
      ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
          // crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
          children: [
            if (isLoading)
              Column(
                children: [
                  Image.asset('assets/loading.gif', width: 250, ),
                  const SizedBox( height: 0, ),
                  const Text( 'Descargando datos...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ) 
                ],
              )
              // const CircularProgressIndicator()
            else 
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // Ajusta según sea necesario
                // crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.cloud_sync_outlined),
                    label: const Text('Sincronizar datos'),
                    onPressed: () {
                      _loadData();
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.start_outlined),
                    label: const Text('Iniciar'),
                    onPressed: () {
                      _navigateTipoEstablecimientos(context);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  
  void _navigateTipoEstablecimientos(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EstablishmentTypesScreen()),
    );
  }

  void _loadData() async {
    setState(() {
      isLoading = true; // Inicia la animación de carga
    });

    await tipoEst.loadFromApiAndSave();

    setState(() {
      isLoading = false; // Detiene la animación de carga cuando el proceso ha terminado
    });
  }

  // void _navigateTipoEstablecimientos(BuildContext context) async {
  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const EstablishmentTypesScreen()),
  //   );
  // }

  // void _loaddata() async {
  //   await tipoEst.loadFromApiAndSave();
  //   //await establecimientos.loadFromApiAndSaveEstablishments();
  // }
}
