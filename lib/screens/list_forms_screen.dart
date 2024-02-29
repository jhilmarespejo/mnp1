import 'package:flutter/material.dart';
import 'package:mnp1/screens/questionnarie_screen.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';

class ListFormsScreen extends StatefulWidget {
  final VisitFormsModel form;
  const ListFormsScreen({Key? key, required this.form}) : super(key: key);

  @override
  State<ListFormsScreen> createState() => _ListFormsScreenState();
}

  class _ListFormsScreenState extends State<ListFormsScreen> {
    late DatabaseProvider listFormProvider;
    final estNombreController = TextEditingController();
    final visTipoController = TextEditingController();
    final visTituloController = TextEditingController();
    final frmTituloController = TextEditingController();
    late int frmIdController;
    
      // get form => null;

    @override
    void initState() {
      super.initState();
      listFormProvider = Provider.of<DatabaseProvider>(
          AppConstants.globalNavKey.currentContext!,
          listen: false);

      estNombreController.text = widget.form.estNombre!;
      visTipoController.text = widget.form.visTipo;
      visTituloController.text = widget.form.visTitulo!;
      frmTituloController.text = widget.form.frmTitulo;
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
              const SizedBox(height: 1),
              Text(visTipoController.text, style: const TextStyle(fontSize: 15)),
            ],
          ),
          elevation: 10,
        ),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16.0),
              child: ListTile(
                // Titulo del formulario con el icono de +
                title: Text('${frmTituloController.text} '),
                trailing: const Icon(Icons.add, size: 45.0),
                onTap: () {
                  _createNewCopyForm(frmIdController, context);
                },
              ),
            ),
            _ListFormsWidget( frmTituloController: frmTituloController, form:widget.form ),
          ],
        ),
      );
    }
  }

  class _ListFormsWidget extends StatelessWidget {
    final TextEditingController frmTituloController;
    final VisitFormsModel form;

    const _ListFormsWidget({ required this.frmTituloController, required this.form});


  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, listFormProvider, _) {
        return listFormProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : listFormProvider.listForms.isEmpty
                ? const Center(
                    child: Text('sin datos', style: TextStyle(fontSize: 18)),
                  )
                : Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        itemCount: listFormProvider.listForms.length,
                        itemBuilder: (context, index) {
                          final listF = listFormProvider.listForms[index];
                          return InkWell(
                            onTap: () {
                              _navigateQuestionnarie( context, listF, form );
                            },
                            child: Card(
                              margin: const EdgeInsets.all(1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Text('(${listF.agfId.toString()})'),
                                              Text(
                                                frmTituloController.text.length > 30
                                                    ? '${frmTituloController.text.substring(0, 30)}...'
                                                    : frmTituloController.text,
                                              ),
                                              // Text('AGF_id: ${listF.agfId.toString()}'),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.edit_document),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
      },
    );
  }


  void _navigateQuestionnarie( BuildContext context, FormGrouperModel listF, VisitFormsModel form) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionnarieScreen( listF: listF, form:form )
      ),
    );
  }
}

  void _createNewCopyForm(int frmId, BuildContext context) async {
    await Provider.of<DatabaseProvider>(
      AppConstants.globalNavKey.currentContext!,
      listen: false,
    ).putNewCopyForm(frmId, context);
  }
