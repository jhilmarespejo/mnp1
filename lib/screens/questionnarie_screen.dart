import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';
// import 'dart:convert';
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

  late PageController _pageController; // Agrega el controlador de la página
  bool isLoading = false; // Variable para controlar la visibilidad del indicador de carga

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
    _pageController = PageController(); // Inicializar el controlador de la página

    // Agregar un listener para detectar cambios de página
    _pageController.addListener(() {
      int currentPage = _pageController.page!.round();
      // print("Cambiado a la página: $currentPage");
      
      // Mostrar el indicador de carga durante la transición de página
      setState(() {
        isLoading = true;
      });


      // Ocultar el indicador de carga después de un breve tiempo (puedes ajustar según tus necesidades)
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          isLoading = false;
        });
      });

    });
    
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
    _pageController.dispose(); // Liberar recursos del controlador de la página
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
          if (isLoading) const LinearProgressIndicator(minHeight: 10.0),
        ],
      ),
    );
  }

  Container footer() {
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