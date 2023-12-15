import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';
import 'dart:convert';

class QuestionnarieScreen extends StatefulWidget {
  final VisitFormsModel form;
  final FormGrouperModel listF;
  const QuestionnarieScreen({super.key, required this.form, required this.listF});

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

  get radioListTiles => null;

  @override
  void initState() {
    super.initState();
    estNombreController.text = widget.form.estNombre ?? '';
    visTipoController.text = widget.form.visTipo;
    frmTituloController.text = widget.form.frmTitulo;
    visTituloController.text = widget.form.visTitulo ?? '';

    frmIdController = widget.form.frmId;

    questionProvider.loadFormsQuestionarie(frmIdController);
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
      body: Column(
        children: [
          header(),
          Expanded(
            child: Container(
              color: Theme.of(context).hoverColor,
              child: PageView.builder(
                itemCount: questionProvider.questions.length,
                itemBuilder: (context, index) {
                  final quizItems = questionProvider.questions[index];
                  return _buildQuestionSlide(quizItems);
                },
              ),
            ),
          ),
          fotter()
        ],
      ),
    );
  }

  Widget _buildQuestionSlide(QuestionnarieModel quizItems) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sub categoría: ${quizItems.catSubcategoria}',
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(
              height: 3,
            ),
            Text(quizItems.bcpPregunta,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.left),
            Text(quizItems.bcpTipoRespuesta,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text(quizItems.bcpOpciones ?? 'sin opciones',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text(quizItems.bcpComplemento ?? 'sin complemento',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            // Convertir la cadena JSON en un mapa de Dart
            responseTypeEvaluation(quizItems),
            // RadioOptionsWidget(options: json.decode(quizItems.bcpOpciones ?? '')),
          ],
        ),
      ),
    );
  }

  Container header() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            frmTituloController.text,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Container fotter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("< Anterior"),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Siguiente >"),
          ),
        ],
      ),
    );
  }
}

Widget responseTypeEvaluation(QuestionnarieModel quizItems) {
  print(quizItems);
  switch (quizItems.bcpTipoRespuesta) {
    case 'Lista desplegable':
      return RadioOptionsWidget(
          options: json.decode(quizItems.bcpOpciones ?? ''));
    case 'Afirmación':
      return RadioOptionsWidget(
          options: json.decode(quizItems.bcpOpciones ?? ''));
    // Puedes agregar más casos según sea necesario
    default:
      // Otro tipo de respuesta, puedes construir un widget diferente o retornar null
      return Text(
          'Tipo de respuesta no compatible: ${quizItems.bcpTipoRespuesta}');
  }
}

class RadioOptionsWidget extends StatefulWidget {
  final Map<String, dynamic> options;
  const RadioOptionsWidget({super.key, required this.options});
  @override
  _RadioOptionsWidgetState createState() => _RadioOptionsWidgetState();
}

class _RadioOptionsWidgetState extends State<RadioOptionsWidget> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    List<Widget> radioListTiles = [];

    widget.options.forEach((key, value) {
      radioListTiles.add(
        RadioListTile<String>(
          title: Text(value),
          value: value,
          groupValue: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
        ),
      );
    });
    print(selectedValue);

    return Column(
      children: radioListTiles,
    );
  }
}
