import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';
import 'dart:convert';
import 'package:device_info/device_info.dart';

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
  late int fkUserIdController;
  late int fkAgfIdController;
  late String uniqueId=''; 

  get radioListTiles => null;

  @override
  void initState() {
    super.initState();
    estNombreController.text = widget.form.estNombre ?? '';
    visTipoController.text = widget.form.visTipo;
    frmTituloController.text = widget.form.frmTitulo;
    visTituloController.text = widget.form.visTitulo ?? '';

    frmIdController = widget.form.frmId;

    fkUserIdController = widget.listF.fkUserId;
    fkAgfIdController = widget.listF.agfId!;

    // Obtener el Android ID y asignarlo a IdUnico
    _getUniqueId();
    questionProvider.loadFormsQuestionnarie(frmIdController);
  }
  Future<void> _getUniqueId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        uniqueId = androidInfo.androidId;
      });
    } catch (e) {
      uniqueId = "alternative-unique-ID-$fkUserIdController";
    }
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
      child: SingleChildScrollView(
        // width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sub categoría: ${quizItems.catSubcategoria}',
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(
              height: 5,
            ),
            Text(quizItems.bcpPregunta,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.left),
            const SizedBox( height: 2,),
            Text(quizItems.bcpTipoRespuesta,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.left),
            Text(quizItems.bcpOpciones ?? 'sin opciones',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text(quizItems.bcpComplemento ?? 'sin complemento',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            // Convertir la cadena JSON en un mapa de Dart
            responseTypeEvaluation(quizItems, fkUserIdController, fkAgfIdController, uniqueId),
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


// se construyen los controles para catipo de pregunta
Widget responseTypeEvaluation(QuestionnarieModel quizItems, int fkUserId, int fkAgfId, String uniqueId) {
  // print(quizItems);
  switch (quizItems.bcpTipoRespuesta) {
    case 'Lista desplegable':
      return RadioButtonsList( quizItems:quizItems, fkUserId:fkUserId, fkAgfId:fkAgfId, uniqueId:uniqueId );
    case 'Afirmación':
      return RadioButtonsList( quizItems:quizItems, fkUserId:fkUserId, fkAgfId:fkAgfId, uniqueId:uniqueId );
    case 'Casilla verificación':
      return CheckBoxesList( quizItems:quizItems,  fkUserId:fkUserId, fkAgfId:fkAgfId, uniqueId:uniqueId);

    case 'Respuesta corta':
      return const AnswerBox( );

    default:
      // Otro tipo de respuesta, puedes construir un widget diferente o retornar null
      return Text(
          'Tipo de respuesta no compatible: ${quizItems.bcpTipoRespuesta}');
  }
}

//Se crean controles radio buttons
class RadioButtonsList extends StatefulWidget {
  final QuestionnarieModel quizItems;
  final int fkUserId;
  final int fkAgfId;
  final String uniqueId;
   const RadioButtonsList({
    Key? key,
    required this.quizItems,
    required this.fkUserId,
    required this.fkAgfId,
    required this.uniqueId,
  }) : super(key: key);
  @override
 RadioButtonsListState createState() => RadioButtonsListState();
}
class RadioButtonsListState extends State<RadioButtonsList> {
  String? selectedValue;
  
  @override
  Widget build(BuildContext context) {
    List<Widget> radioListTiles = [];
    Map<String, dynamic>? opciones = json.decode(widget.quizItems.bcpOpciones ?? '{}');
    opciones?.forEach((key, value) {
      radioListTiles.add(
        RadioListTile<String>(
          title: Text(value),
          value: value,
          groupValue: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
              saveSelectedAnswerToDatabase( context, value, widget);
            });
          },
        ),
      );
    });
    // print(selectedValue);
    return SingleChildScrollView(
      child: Column(
        children: radioListTiles,
      ),
    );
  }

  
}
void saveSelectedAnswerToDatabase(BuildContext context, String selectedAnswer, dynamic widget) async {
    // Obtener la instancia del proveedor de base de datos
    DatabaseProvider databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);

    AnswersModel answer = AnswersModel(
      resRespuesta: selectedAnswer,
      fkRbfId: widget.quizItems.rbfId,
      fkAgfId: widget.fkAgfId,
      userId: widget.fkUserId,
      deviceId: widget.uniqueId
    );
  // print(answer.resRespuesta);
  // print(answer.fkRbfId);
  // print(answer.fkAgfId);
  // print(answer.userId);
  // print(answer.deviceId);
    // Guardar la respuesta en la base de datos
    await databaseProvider.saveAnswer(answer);
  }

//Se crean controles para checkList
class CheckBoxesList extends StatefulWidget {
  final QuestionnarieModel quizItems;
  final int fkUserId;
  final int fkAgfId;
  final String uniqueId;
  const CheckBoxesList({
   Key? key,
    required this.quizItems,
    required this.fkUserId,
    required this.fkAgfId,
    required this.uniqueId,
  }) : super(key: key);

  @override
  CheckBoxesListState createState() => CheckBoxesListState();
}

class CheckBoxesListState extends State<CheckBoxesList> {
  List<String> selectedValues = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> checkBoxListTiles = [];
    Map<String, dynamic>? opciones = json.decode(widget.quizItems.bcpOpciones ?? '{}');

    opciones?.forEach((key, value) {
      checkBoxListTiles.add(
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading, // Muestra el checkbox antes del texto
          title: Text(value),
          value: selectedValues.contains(value),
          onChanged: (bool? isChecked) {
            setState(() {
              if (isChecked!) {
                selectedValues.add(value);
                saveSelectedAnswerToDatabase( context, value, widget);
              } else {
                selectedValues.remove(value);
              }
            });
          },
        ),
      );
    });
    // print(selectedValues);
    return SingleChildScrollView(
      child: Column(
        children: checkBoxListTiles,
      ),
    );
  }
}



class AnswerBox extends StatefulWidget {
  const AnswerBox({Key? key}) : super(key: key);

  @override
  LongAnswerBoxState createState() => LongAnswerBoxState();
}

class LongAnswerBoxState extends State<AnswerBox> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Respuesta larga:',
          style: TextStyle(fontSize: 15),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 3),
        TextField(
          controller: textController,
          maxLines: 2, // Puedes ajustar el número de líneas según tus necesidades
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Escribe la respuesta aquí...',
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

