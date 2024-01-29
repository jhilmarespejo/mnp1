import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
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
  late int fkUserIdController;
  late int fkAgfIdController;
  late String uniqueId=''; 

  get radioListTiles => null;

  late PageController _pageController; // Agrega el controlador de la página
  bool isLoading = false; // Variable para controlar la visibilidad del indicador de carga
  // Map<int, Key> pageKeysMap = {};

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
    // Antes de construir el PageView.builder
    // for (final quizItems in questionProvider.questions) {
    //   final bcpId = quizItems[0]['FK_BCP_id'];
    //   pageKeysMap[bcpId] = GlobalKey();
    // }
    
    questionProvider.loadFormsQuestionnarie(frmIdController, fkAgfIdController);
    _pageController = PageController(); // Inicializar el controlador de la página   
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
  void dispose() {
    //_pageController.dispose(); // Liberar recursos del controlador de la página
    super.dispose();
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
                controller: _pageController, // Usar el controlador de la página
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questionProvider.questions.length,
                itemBuilder: (context, index) {
                  final quizItems = questionProvider.questions[index];
                  return _buildQuestionSlide([quizItems]);
                },
              ),
            ),
          ),
          
          footer()
        ],
      ),
    );
  }

  Widget _buildQuestionSlide(List<Map<String, dynamic>> quizItems) {
  
    return Padding(
      key: ValueKey<int>(quizItems[0]['FK_BCP_id']),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
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
            Text('KF_RBF_id: ${quizItems[0]['RBF_id']}' ,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text('FK_BCP_id: ${quizItems[0]['FK_BCP_id']}' ,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            Text('Respuetas: ${quizItems[0]['RES_respuesta']}' ,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left),
            // Convertir la cadena JSON en un mapa de Dart
            responseTypeEvaluation(quizItems, uniqueId),
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
          // Mostrar el indicador de carga cuando isLoading es true
         
        ],
      ),
    );
  }

  Container footer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(minHeight: 2.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
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
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text(">"),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

}


// ****************************************************************************************************

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
    final String responseType = widget.quizItems[0]['BCP_tipoRespuesta'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if( widget.quizItems[0]['BCP_tipoRespuesta'] == 'Respuesta larga' )
          const SizedBox(height: 3),
          TextField(
            controller: textController,
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
    textController.dispose();
    super.dispose();
  }
}





//*** FUNCION AUXILIAR PARA VERIFICAR LAS RESPUESTAS */
final dbhelper = DatabaseHelper();
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