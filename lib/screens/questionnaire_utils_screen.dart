// questionnaire_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
// import '../app_constants.dart';
import 'dart:convert';

late TextEditingController responsesController;
late List<Map<String, dynamic>> responsePerPage; 

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
  final String uniqueId;
  const CheckBoxesList({
   Key? key,
    required this.quizItems,
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
              responsePerPage = [{
                'RBF_id': widget.quizItems[0]['RBF_id'],
                'AGF_id': widget.quizItems[0]['AGF_id'],
                'USER_id':  widget.quizItems[0]['FK_USER_id'],
                'RES_device_id': widget.uniqueId,
                'RES_respuesta': selectedValues.isEmpty? null : jsonEncode(selectedValues), // Agrega el valor del controlador de texto
              }];
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
  final String uniqueId;
   const RadioButtonsList({
    Key? key,
    required this.quizItems,
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
            });
          },
        ),
      );
    });
    
    responsePerPage = [{
      'RBF_id': widget.quizItems[0]['RBF_id'],
      'AGF_id': widget.quizItems[0]['AGF_id'],
      'USER_id':  widget.quizItems[0]['FK_USER_id'],
      'RES_device_id': widget.uniqueId,
      'RES_respuesta': selectedValue, // Agrega el valor del controlador de texto
    }];
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
void saveSelectedAnswerToDatabase(BuildContext context, List<Map<String, dynamic>> responsePerPage) async {
  
  print(responsePerPage[0]['RBF_id']);
  print(responsePerPage[0]['RES_respuesta']);
  DatabaseProvider databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  // AnswersModel answer = AnswersModel(
  //   resRespuesta: selectedAnswer,
  //   fkRbfId: widget.quizItems[0]['RBF_id'],
  //   fkAgfId: widget.quizItems[0]['AGF_id'],
  //   userId: widget.quizItems[0]['FK_USER_id'],
  //   deviceId: widget.uniqueId
  // );

  // dynamic existingAnswer = await databaseProvider.checkExistingAnswer(answer.fkRbfId, answer.fkAgfId);
  // if(existingAnswer is List && existingAnswer.isEmpty){
  //   await databaseProvider.putNewAnswer(answer);
  // }  else {
  //   await databaseProvider.updateAnswer(answer.resRespuesta, answer.fkRbfId, answer.fkAgfId);
  // }
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
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.quizItems[0]['BCP_tipoRespuesta']);
    final String responseType = widget.quizItems[0]['BCP_tipoRespuesta'];

    responsePerPage = [{
      'RBF_id': widget.quizItems[0]['RBF_id'],
      'AGF_id': widget.quizItems[0]['AGF_id'],
      'USER_id':  widget.quizItems[0]['FK_USER_id'],
      'RES_device_id': widget.uniqueId,
      'RES_respuesta': null, // Agrega el valor del controlador de texto
    }];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const SizedBox(height: 3),
          TextField(
            controller: responsesController, 
            maxLines: responseType == 'Respuesta larga'? 2: 1,
            inputFormatters: responseType == 'Numeral'? [FilteringTextInputFormatter.digitsOnly] : null,
             keyboardType: responseType == 'Numeral'? TextInputType.number : null, // Define el tipo de teclado
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
    super.dispose();
  }
}


