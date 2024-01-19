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
    
    questionProvider.loadFormsQuestionnarie(frmIdController, fkAgfIdController);
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
                  return _buildQuestionSlide([quizItems]);
                },
              ),
            ),
          ),
          
          fotter()
        ],
      ),
    );
  }

  Widget _buildQuestionSlide(List<Map<String, dynamic>> quizItems) {
    print(quizItems[0]['CAT_subcategoria']);
    // for (var item in quizItems) {
    // }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sub categoría: ${quizItems[0]['CAT_subcategoria']}',
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(
              height: 5,
            ),
            Text(quizItems[0]['BCP_pregunta'],
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.left),
            const SizedBox( height: 2,),
            Text(quizItems[0]['BCP_tipoRespuesta'] ?? '---',
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.left),
            Text(quizItems[0]['BCP_opciones'] ?? 'sin opciones',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text(quizItems[0]['BCP_complemento'] ?? 'sin complemento',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text('KF_AGF_id: $fkAgfIdController' ,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text('KF_RBF_id: ${quizItems[0]['RBF_id']}' ,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text('Respuetas: ${quizItems[0]['RES_respuesta']}' ,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            // Convertir la cadena JSON en un mapa de Dart
            responseTypeEvaluation(quizItems, fkUserIdController, fkAgfIdController, uniqueId),
            // RadioOptionsWidget(options: json.decode(quizItems[0]['bcpOpciones'] ?? '')),
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
            child: const Text("<"),
          ),
          ElevatedButton(
            onPressed: () {_viewAnswers();},
            child: const Text("RESP"),
          ),
          ElevatedButton(
            onPressed: () {_queryDelR();},
            child: const Text("Elim RESP"),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text(">"),
          ),
        ],
      ),
    );
  }

}


// se construyen los controles para catipo de pregunta
Widget responseTypeEvaluation(List<Map<String, dynamic>> quizItems, int fkUserId, int fkAgfId, String uniqueId) {
  // print(quizItems);
  switch (quizItems[0]['BCP_tipoRespuesta']) {
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
          'Tipo de respuesta no compatible: ${quizItems[0]['BCP_tipoRespuesta']}');
  }
}

//Se crean controles radio buttons
class RadioButtonsList extends StatefulWidget {
  final List<Map<String, dynamic>> quizItems;
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
    Map<String, dynamic>? opciones = json.decode(widget.quizItems[0]['BCP_opciones'] ?? '{}');
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
    print(selectedValue);
    return SingleChildScrollView(
      child: Column(
        children: radioListTiles,
      ),
    );
  }

  
}
void saveSelectedAnswerToDatabase(BuildContext context, dynamic selectedAnswer, dynamic widget) async {
    // Obtener la instancia del proveedor de base de datos
    DatabaseProvider databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    AnswersModel answer = AnswersModel(
      resRespuesta: selectedAnswer,
      fkRbfId: widget.quizItems[0]['RBF_id'],
      fkAgfId: widget.fkAgfId,
      userId: widget.fkUserId,
      deviceId: widget.uniqueId
    );
  // print(answer.resRespuesta);
  // print(answer.fkRbfId);
  // print(answer.fkAgfId);
  // print(answer.userId);
  // print(answer.deviceId);
  //   Guardar la respuesta en la base de datos
  
  dynamic existingAnswer = await databaseProvider.checkExistingAnswer(answer.fkRbfId, answer.fkAgfId);
    if(existingAnswer is List && existingAnswer.isEmpty){
      // print('GUARDAR');
      await databaseProvider.putNewAnswer(answer);
    }  else {
      // print(answer.resRespuesta);
      await databaseProvider.updateAnswer(answer.resRespuesta, answer.fkRbfId, answer.fkAgfId);
    }
  }
  
//Se crean controles para checkList
class CheckBoxesList extends StatefulWidget {
  final List<Map<String, dynamic>> quizItems;
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
    Map<String, dynamic>? opciones = json.decode(widget.quizItems[0]['BCP_opciones'] ?? '{}');

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
                
              } else {
                selectedValues.remove(value);
              }
              if (selectedValues.isEmpty) {
                // print('array vacio');
                saveSelectedAnswerToDatabase( context, null, widget);
              } else {
                // print(jsonEncode(selectedValues));
                saveSelectedAnswerToDatabase( context, jsonEncode(selectedValues), widget);
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

final dbhelper = DatabaseHelper();
//*** FUNCION AUXILIAR PARA VERIFICAR LAS RESPUESTAS */
void _viewAnswers() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<AnswersModel> resultados = await dbHelper.getAnswers();
    for (var resultado in resultados) {
      print('Respuesta: ${resultado.resRespuesta},FK_RBF_id: ${resultado.fkRbfId},FK_AGF_id: ${resultado.fkAgfId}, USER_id: ${resultado.userId} ');
    }
}
void _queryDelR() async {
  await dbhelper.delRespuestas();
    // print(result);
}