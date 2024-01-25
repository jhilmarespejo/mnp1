// questionnaire_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
// import '../app_constants.dart';
import 'dart:convert';
// import 'package:device_info/device_info.dart';

Widget responseTypeEvaluation(List<Map<String, dynamic>> quizItems, String uniqueId) {
  if( quizItems[0]['BCP_tipoRespuesta'] == 'Lista desplegable' || quizItems[0]['BCP_tipoRespuesta'] == 'Afirmación' ){
    return RadioButtonsList( quizItems:quizItems, uniqueId:uniqueId );
  }else if(quizItems[0]['BCP_tipoRespuesta'] == 'Casilla verificación'){
    return CheckBoxesList( quizItems:quizItems,  uniqueId:uniqueId);
  }
  else if(quizItems[0]['BCP_tipoRespuesta'] == 'Respuesta corta' || quizItems[0]['BCP_tipoRespuesta'] == 'Respuesta larga' || quizItems[0]['BCP_tipoRespuesta'] == 'Numeral'){
    return AnswerBox( quizItems:quizItems,  uniqueId:uniqueId );
  } else {
    return Text('Tipo de respuesta no compatible: ${quizItems[0]['BCP_tipoRespuesta']}');
  }
}

//Se crean controles para checkList
class CheckBoxesList extends StatefulWidget {
  final List<Map<String, dynamic>> quizItems;
  // final int fkUserId;
  // final int fkAgfId;
  final String uniqueId;
  const CheckBoxesList({
   Key? key,
    required this.quizItems,
    // required this.fkUserId,
    // required this.fkAgfId,
    required this.uniqueId,
  }) : super(key: key);

  @override
  CheckBoxesListState createState() => CheckBoxesListState();
}

class CheckBoxesListState extends State<CheckBoxesList> {
  List<String> selectedValues = [];


    @override
    void initState() {
      super.initState();
      // Obtener respuestas prealmacenadas y marcar las opciones correspondientes
      String? storedAnswers = widget.quizItems[0]['RES_respuesta'];
      if (storedAnswers != null && storedAnswers.isNotEmpty) {
        List<String> storedValues = json.decode(storedAnswers).cast<String>();
        selectedValues.addAll(storedValues);
      }
    }

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

  void updateSelectedValues(String value) {
    setState(() {
      if (selectedValues.contains(value)) {
        selectedValues.remove(value);
      } else {
        selectedValues.add(value);
      }
    });
  }
}

//Se crean controles radio buttons
class RadioButtonsList extends StatefulWidget {
  final List<Map<String, dynamic>> quizItems;
  // final int fkUserId;
  // final int fkAgfId;
  final String uniqueId;
   const RadioButtonsList({
    Key? key,
    required this.quizItems,
    // required this.fkUserId,
    // required this.fkAgfId,
    required this.uniqueId,
  }) : super(key: key);

  @override
 RadioButtonsListState createState() => RadioButtonsListState();
}

class RadioButtonsListState extends State<RadioButtonsList> {
  String? selectedValue;
  
  @override
  void initState() {
    super.initState();

    // Obtener respuesta prealmacenada y establecerla como seleccionada
    String? storedAnswer = widget.quizItems[0]['RES_respuesta'];
    if (storedAnswer != null && storedAnswer.isNotEmpty) {
      selectedValue = storedAnswer;
    }
  }
  
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
    // print(selectedValue);
    return SingleChildScrollView(
      child: Column(
        children: radioListTiles,
      ),
    );
  }
  
  void updateSelectedValue(String value) {
    setState(() {
      selectedValue = value;
    });
  }
}

//Guarda o actualiza los datos en la base 
void saveSelectedAnswerToDatabase(BuildContext context, dynamic selectedAnswer, dynamic widget) async {
  DatabaseProvider databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  AnswersModel answer = AnswersModel(
    resRespuesta: selectedAnswer,
    fkRbfId: widget.quizItems[0]['RBF_id'],
    fkAgfId: widget.quizItems[0]['AGF_id'],
    userId: widget.quizItems[0]['FK_USER_id'],
    // fkAgfId: widget.fkAgfId,
    // userId: widget.fkUserId,
     deviceId: widget.uniqueId
  );

  dynamic existingAnswer = await databaseProvider.checkExistingAnswer(answer.fkRbfId, answer.fkAgfId);
  if(existingAnswer is List && existingAnswer.isEmpty){
    await databaseProvider.putNewAnswer(answer);
  }  else {
    await databaseProvider.updateAnswer(answer.resRespuesta, answer.fkRbfId, answer.fkAgfId);
  }
}


class AnswerBox extends StatefulWidget {
  final List<Map<String, dynamic>> quizItems;
  final String uniqueId;
  const AnswerBox({Key? key,
    required this.quizItems,
    required this.uniqueId,
  }) : super(key: key);

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
    // print(widget.quizItems[0]['BCP_tipoRespuesta']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if( widget.quizItems[0]['BCP_tipoRespuesta'] == 'Respuesta larga' )
        ...[
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
        if(widget.quizItems[0]['BCP_tipoRespuesta'] == 'Respuesta corta' )
        ...[
          const SizedBox(height: 3),
          TextField(
            controller: textController,
            maxLines: 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Escribe la respuesta aquí...',
            ),
          ),
        ],
        if(widget.quizItems[0]['BCP_tipoRespuesta'] == 'Numeral' )
        ...[
          const SizedBox(height: 3),
          TextField(
            controller: textController,
            maxLines: 1,
            keyboardType: TextInputType.number, // Define el tipo de teclado
            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Permite solo dígitos
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Escribe la respuesta aquí...',
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
