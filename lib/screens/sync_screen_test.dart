import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
import 'package:mnp1/screens/sync_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class SyncScreenTest extends StatelessWidget {
  const SyncScreenTest({super.key});

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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.cloud_sync_outlined),
              label: const Text('Sincronizar datos'),
              onPressed: () {
                // _loaddata();
                _verifyUser(context);
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
              icon: const Icon(Icons.question_answer),
              label: const Text('Consulta X'),
              onPressed: () {
                _queryX();
              },
            ),
            const SizedBox(
              height: 30,
            ),
            FilledButton.icon(
              icon: const Icon(Icons.start_outlined),
              label: const Text('Iniciar'),
              onPressed: () {
                _navigateTipoEstablecimientos(context);
              },
            ),
            const SizedBox(
              height: 30,
            ),
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('LOGIN'),
              onPressed: () {
                _navigateLogin(context);
              },
            ),
            FilledButton.icon(
              icon: const Icon(Icons.key),
              label: const Text('TOKEN'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');
                int? userId = prefs.getInt('userId');
                print(token);
                print(userId);
              },
            ),
            FilledButton.icon(
              icon: const Icon(Icons.key),
              label: const Text('destroy TOKEN'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
              },
            ),
            FilledButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete respuestas'),
              onPressed: () async {
                _deleteRespuestas();
              },
            ),
            FilledButton.icon(
                icon: const Icon(Icons.abc_rounded),
                label: const Text('first screen'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SyncScreen()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  void _verifyUser(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    print(userId);


    //_loaddata();
    // _showConfirmationDialog(context);

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
  }

  void _loaddata() async {
    await tipoEst.loadFromApiAndSave();
  }

  void _getdata() async {
    await tipoEst.getData();
  }

  void _queryX() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<AnswersModel> resultados = await dbHelper.getAnswers();
    
  }
  void _deleteRespuestas() async {
    // DatabaseHelper dbHelper = DatabaseHelper();
    // List<AnswersModel> resultados = await dbHelper.delRespuestas();
    await tipoEst.delRespuestas();
  }

  void _deletedata() async {
    await tipoEst.deleteData();
  }
}
