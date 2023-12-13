import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';

class QuestionnarieScreen extends StatefulWidget {
  final VisitFormsModel form;
  const QuestionnarieScreen({super.key, required this.form});

  @override
  State<QuestionnarieScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<QuestionnarieScreen> {
  final questionProvider =
      Provider.of<DatabaseProvider>(AppConstants.globalNavKey.currentContext!);
  late int frmIdController;
  late TextEditingController estNombreController = TextEditingController();
  late TextEditingController visTipoController = TextEditingController();

  late TextEditingController frmTituloController = TextEditingController();
  late TextEditingController visTituloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // tesTipoController.text = widget.type.tesTipo;
    estNombreController.text = widget.form.estNombre ?? '';
    visTipoController.text = widget.form.visTipo;
    frmTituloController.text = widget.form.frmTitulo;
    visTituloController.text = widget.form.visTitulo?? '';

    frmIdController = widget.form.frmId;


    questionProvider.loadFormsQuestionarie(frmIdController);
  }

  @override
  Widget build(BuildContext context) {
    // final questions = questionProvider.questions[index];
    return Scaffold(
      appBar: AppBar(
        // title: Text(estNombreController.text),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(estNombreController.text),
            const SizedBox( height: 1, ),
            Text(visTipoController.text, style: const TextStyle(fontSize: 15) ),
            // const SizedBox( height: 1, ),
            // Text(visTituloController.text, style: const TextStyle(fontSize: 15) ),
          ],
        ),
       
        elevation: 10,
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity, // Ocupa todo el ancho disponible
            // child: Text( 'Encabezadoffff', ),
            child: Column(
              children: [
                Text( frmTituloController.text, style: const TextStyle(fontSize: 15), textAlign:TextAlign.center ,),
              ],

            )
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).focusColor, // Color del tema predefinido
              // width: double.infinity, // Ocupa todo el ancho disponible
              child: PageView.builder(
                itemCount: questionProvider.questions.length,
                itemBuilder: (context, index) {
                  final q = questionProvider.questions[index];
                  return _buildQuestionSlide(q);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity, // Ocupa todo el ancho disponible
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () { },
                  child: const Text("< Anterior"),
                ),
                ElevatedButton(
                  onPressed: () { },
                  child: const Text("Siguiente >"),
                ),
              ],
            ),
          )
        ],
      ),
      
    );
  }

  Widget _buildQuestionSlide(QuestionnarieModel q) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sub categoría: ${q.catSubcategoria}', style: const TextStyle(fontSize: 15), textAlign:TextAlign.center ),
            const SizedBox( height: 3, ),
            Text(q.bcpPregunta, style: const TextStyle(fontSize: 22), textAlign:TextAlign.left ),
          ],
        ),
      ),
    );
  }
}
