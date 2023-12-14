import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';
// import 'package:flutter/material.dart';

class ListFormsScreen extends StatefulWidget {
  final VisitFormsModel form;
  const ListFormsScreen({super.key, required this.form});

  @override
  State<ListFormsScreen> createState() => _ListFormsScreenState();
}

class _ListFormsScreenState extends State<ListFormsScreen> {
  final listFormProvider =
      Provider.of<DatabaseProvider>(AppConstants.globalNavKey.currentContext!);

  final estNombreController = TextEditingController();
  var visTipoController = TextEditingController();
  var visTituloController = TextEditingController();
  late int frmIdController;

  @override
  void initState() {
    super.initState();
    estNombreController.text = widget.form.estNombre!;
    visTipoController.text = widget.form.visTipo;
    visTituloController.text = widget.form.visTitulo!;
    frmIdController = widget.form.frmId;
    listFormProvider.loadListForms(frmIdController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(estNombreController.text),
            const SizedBox(
              height: 1,
            ),
            Text(visTipoController.text, style: const TextStyle(fontSize: 15)),
          ],
        ),
        elevation: 10,
      ),
      body: const _ListFormsWidget(),
    );
  }
}

class _ListFormsWidget extends StatelessWidget {
  const _ListFormsWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, listFormProvider, _) {
        return listFormProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            // : listFormProvider.listForms.isEmpty
            //     ? const Center(
            //         child: Text('sin datos', style: TextStyle(fontSize: 18)))
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: listFormProvider.listForms.length,
                  itemBuilder: (context, index) {
                    final listF = listFormProvider.listForms[index];
                    return OutlinedButton.icon(
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(listF.fkFrmId as String),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_outlined),
                      onPressed: () {
                        // _navigateEstablecimientos( context, type );
                      },
                    );
                  },
                ),
              );
      },
    );
  }
}
