// questionnaire_utils.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
// import '../app_constants.dart';
import 'dart:convert';
// import 'package:device_info/device_info.dart';

Widget responseTypeEvaluation(List<Map<String, dynamic>> quizItems, int fkUserId, int fkAgfId, String uniqueId) {
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

//Guarda o actualiza los datos en la base 
void saveSelectedAnswerToDatabase(BuildContext context, dynamic selectedAnswer, dynamic widget) async {
  DatabaseProvider databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  AnswersModel answer = AnswersModel(
    resRespuesta: selectedAnswer,
    fkRbfId: widget.quizItems[0]['RBF_id'],
    fkAgfId: widget.fkAgfId,
    userId: widget.fkUserId,
    deviceId: widget.uniqueId
  );

  dynamic existingAnswer = await databaseProvider.checkExistingAnswer(answer.fkRbfId, answer.fkAgfId);
  if(existingAnswer is List && existingAnswer.isEmpty){
    await databaseProvider.putNewAnswer(answer);
  }  else {
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
          controlAffinity: ListTileControlAffinity.leading,
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
                saveSelectedAnswerToDatabase( context, null, widget);
              } else {
                saveSelectedAnswerToDatabase( context, jsonEncode(selectedValues), widget);
              }
            });
          },
        ),
      );
    });
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
          maxLines: 2,
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
