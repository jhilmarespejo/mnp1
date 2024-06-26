// questionnaire_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
// import '../app_constants.dart';
import 'dart:convert';

// import 'package:mnp1/config/providers/database_provider.dart';

late TextEditingController responsesController;
late TextEditingController complementController;
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
  // String? complementaryAnswer;
    @override
    void initState() {
      super.initState();
      // Obtener respuestas prealmacenadas y marcar las opciones correspondientes
      String? storedAnswers = widget.quizItems[0]['RES_respuesta'];
      if (storedAnswers != null && storedAnswers.isNotEmpty) {
        List<String> storedValues = json.decode(storedAnswers).cast<String>();
        selectedValues.addAll(storedValues);
      }
      // Se obtiene la respuesta complementaria
      String? storedComplementaryAnswer = widget.quizItems[0]['RES_complemento'];
      if (storedComplementaryAnswer != null && storedComplementaryAnswer.isNotEmpty) {
        complementController.text = storedComplementaryAnswer;
      }
    }

  @override
  Widget build(BuildContext context) {
    List<Widget> checkBoxListTiles = [];
    Map<String, dynamic>? opciones = json.decode(widget.quizItems[0]['BCP_opciones'] ?? '{}');

    // Verifica si BCP_complemento tiene contenido
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
                'FK_USER_id':  widget.quizItems[0]['FK_USER_id'],
                'RES_device_id': widget.uniqueId,
                'RES_respuesta': selectedValues.isEmpty? null : jsonEncode(selectedValues), // Agrega el valor del controlador de texto
                'RES_complemento': null, // Agrega el valor del controlador de texto
                'RBF_salto_FK_BCP_id': widget.quizItems[0]['RBF_salto_FK_BCP_id'],
                'FK_BCP_id': widget.quizItems[0]['FK_BCP_id'],
              }];
            });
          },
        ),
      );
    });
    if (widget.quizItems[0]['BCP_complemento'] != null &&
        widget.quizItems[0]['BCP_complemento'].isNotEmpty) {
      // Agrega un TextField si BCP_complemento tiene contenido
      checkBoxListTiles.add(
        TextField(
          controller: complementController, 
          maxLines: 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: widget.quizItems[0]['BCP_complemento'] ,
          ),
          // Configuración del TextField según tus necesidades
        ),
      );
    }
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

    String? storedComplementaryAnswer = widget.quizItems[0]['RES_complemento'];
    if (storedComplementaryAnswer != null && storedComplementaryAnswer.isNotEmpty) {
      complementController.text = storedComplementaryAnswer;
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
    if (widget.quizItems[0]['BCP_complemento'] != null &&
      widget.quizItems[0]['BCP_complemento'].isNotEmpty) {
      // Si hay contenido en BCP_complemento, agrega un TextField
      radioListTiles.add(
        TextField(
          controller: complementController, 
          maxLines: 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: widget.quizItems[0]['BCP_complemento'],
          ),
        ),
      );
    }
    
    responsePerPage = [{
      'RBF_id': widget.quizItems[0]['RBF_id'],
      'AGF_id': widget.quizItems[0]['AGF_id'],
      'FK_USER_id':  widget.quizItems[0]['FK_USER_id'],
      'RES_device_id': widget.uniqueId,
      'RES_respuesta': selectedValue, // Agrega el valor del controlador de texto
      'RES_complemento':null,
      'RBF_salto_FK_BCP_id': widget.quizItems[0]['RBF_salto_FK_BCP_id'],
      'FK_BCP_id': widget.quizItems[0]['FK_BCP_id'],
    }];
      
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
  DatabaseProvider databaseProvider =
    Provider.of<DatabaseProvider>(context, listen: false);
  AnswersModel answer = AnswersModel(
    resRespuesta: responsePerPage[0]['RES_respuesta'],
    fkRbfId: responsePerPage[0]['RBF_id'],
    fkAgfId: responsePerPage[0]['AGF_id'],
    userId: responsePerPage[0]['FK_USER_id'],
    deviceId: responsePerPage[0]['RES_device_id'],
    resComplemento: responsePerPage[0]['RES_complemento'],
    
  );

  // Se verifica si la respuesta ya existe, si es asi, se actualiza la respuesta
  dynamic existingAnswer = await databaseProvider.checkExistingAnswer(answer.fkRbfId, answer.fkAgfId);
  if(existingAnswer is List && existingAnswer.isEmpty){
    await databaseProvider.putNewAnswer(answer);
  }  else {
    await databaseProvider.updateAnswer(answer.resRespuesta, answer.fkRbfId, answer.fkAgfId);
  }
}

//  Respuestas de tipo texto
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
    String? actualStoredAnswer = widget.quizItems[0]['RES_respuesta'];
    Future.delayed(Duration.zero, () {
      if (actualStoredAnswer != null && actualStoredAnswer.isNotEmpty) {
        responsesController.text = actualStoredAnswer;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String responseType = widget.quizItems[0]['BCP_tipoRespuesta'];

    responsePerPage = [{
      'RBF_id': widget.quizItems[0]['RBF_id'],
      'AGF_id': widget.quizItems[0]['AGF_id'],
      'FK_USER_id':  widget.quizItems[0]['FK_USER_id'],
      'RES_device_id': widget.uniqueId,
      'RES_respuesta': null, // el valor se asigna despues
      'RES_complemento': null,
      'RBF_salto_FK_BCP_id': widget.quizItems[0]['RBF_salto_FK_BCP_id'],
      'FK_BCP_id': widget.quizItems[0]['FK_BCP_id'],
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


