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
                      _verifyUser(context);
                      // _showConfirmationDialogDowload(context);
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
                      _showConfirmationDialogUPload(context);
                      // _uploadData();
                    },
                  ),
                  // FilledButton.icon(
                  //   icon: const Icon(Icons.abc_rounded),
                  //   label: const Text('test screen'),
                  //   onPressed: () {
                  //     Navigator.pushReplacement(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => const SyncScreenTest()),
                  //     );
                  //   },
                  // ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _verifyUser(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId != null) {
      // ignore: use_build_context_synchronously
      _showConfirmationDialogDowload(context);

    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }

    // 

  }
  void _showConfirmationDialogDowload(BuildContext context) {
    showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmación'),
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Text('Los '),
          // SizedBox(height: 8), // Espacio entre el texto "Atención" y el texto de la pregunta
          Text('¿Está seguro de sincronizar los datos?'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _loadData();
          },
          child: Text('Sí'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('No'),
        ),
      ],
    );
  },
);
  }
  void _showConfirmationDialogUPload(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
        title: Row(
          children: [
            const Text('Atención!'),
            const Icon(Icons.warning, color: Colors.yellow), // Agregar un icono de advertencia
          ],
        ),
        content: const Text('Asegúrese de que la información esté completa y sea confiable'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadData();
            },
            child: const Text('Enviar información'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Retroceder'),
          ),
        ],
      );
      },
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
