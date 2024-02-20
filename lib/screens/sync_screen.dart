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
  bool isUpLoading = false;
  bool isDownLoading = false;

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
            if ( isUpLoading )
              Column(
                children: [
                  Image.asset('assets/downloading.gif', width: 250, ),
                  const SizedBox( height: 0, ),
                  const Text( 'Sincronizando datos...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ) 
                ],
              )
            else if ( isDownLoading )
              Column(
                children: [
                  Image.asset('assets/uploading.gif', width: 250, ),
                  const SizedBox( height: 0, ),
                  const Text( 'Enviando respuestas...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ) 
                ],
              )

            else 
              Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.download),
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
                  const SizedBox(
                    height: 50,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Sincronizar respuestas'),
                    onPressed: () {
                      _uploadData();
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
      isUpLoading = true; // Inicia la animación de carga
    });

    await tipoEst.loadFromApiAndSave();

    setState(() {
      isUpLoading = false; // Detiene la animación de carga cuando el proceso ha terminado
    });
  }
  void _uploadData() async {
    setState(() {
      isDownLoading = true; // Inicia la animación de carga
    });

    await tipoEst.uploadData();

    setState(() {
      isDownLoading = false; // Detiene la animación de carga cuando el proceso ha terminado
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
