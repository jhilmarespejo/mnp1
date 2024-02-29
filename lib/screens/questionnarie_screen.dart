import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mnp1/config/files.dart';
import '../app_constants.dart';

// import 'package:flutter/services.dart';
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
  late String fkAgfIdController;
  late String uniqueId='xxx'; 

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
    responsesController = TextEditingController(); 
    complementController = TextEditingController(); 
    responsePerPage = [];
  }

    // final DatabaseHelper deviceId = DatabaseHelper();
    // final uniqueId = deviceId.getUniqueId();


 Future<String> _getUniqueId() async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return uniqueId = androidInfo.androidId;
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questionProvider.questions.length+1,
                itemBuilder: (context, index) {
                  if ( index < questionProvider.questions.length ) {
                    final quizItems = questionProvider.questions[index];
                    return _buildQuestionSlide([quizItems], index);
                  } else {
                    return _buildAdditionalPage();
                  }
                },
              ),
            ),
          ),
          
          footer()
        ],
      ),
    );
  }
  Widget _buildAdditionalPage() {
    return Container(
    // Aquí puedes construir la página adicional
    alignment: Alignment.center,
    child: FilledButton.icon(
      icon: const Icon(Icons.arrow_back_ios),
      label: const Text('Fin del cuestionario'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
  }
  Widget _buildQuestionSlide(List<Map<String, dynamic>> quizItems, int index) {
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
            Text('${index+1}. ${quizItems[0]['BCP_pregunta']}',
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.left),
            const SizedBox( height: 2,),
            // Text(quizItems[0]['BCP_tipoRespuesta'] ?? '---',
            //     style: const TextStyle(fontSize: 15),
            //     textAlign: TextAlign.left),
            // Text(quizItems[0]['BCP_opciones'] ?? 'sin opciones',
            //     style: const TextStyle(fontSize: 12),
            //     textAlign: TextAlign.left),
            // Text(quizItems[0]['BCP_complemento'] ?? 'sin complemento',
            //     style: const TextStyle(fontSize: 12),
            //     textAlign: TextAlign.left),
            // Text('KF_AGF_id: $fkAgfIdController' ,
            //     style: const TextStyle(fontSize: 12),
            //     textAlign: TextAlign.left),
            // Text('KF_RBF_id: ${quizItems[0]['RBF_id']}' ,
            //     style: const TextStyle(fontSize: 12),
            //     textAlign: TextAlign.left),
            // Text('FK_BCP_id: ${quizItems[0]['FK_BCP_id']}' ,
            //     style: const TextStyle(fontSize: 12),
            //     textAlign: TextAlign.left),
            // Text('Respuetas: ${quizItems[0]['RES_respuesta']}' ,
            //     style: const TextStyle(fontSize: 12),
            //     textAlign: TextAlign.left),
            responseTypeEvaluation(quizItems, uniqueId),
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
          const SizedBox( height: 2,),
          Text('($fkAgfIdController)',
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.left),
         
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
                  if(responsesController.text != '' && responsePerPage[0]['RES_respuesta'] == null ) {
                    responsePerPage[0]['RES_respuesta'] = responsesController.text; // Agrega el valor del controlador de texto
                  } 

                  if( complementController.text !='' ){
                    responsePerPage[0]['RES_complemento'] = complementController.text;
                  }

                  saveSelectedAnswerToDatabase(context, responsePerPage);
                  
                  responsesController.clear();
                  complementController.clear();
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
// ****************************************************************************************************
// ****************************************************************************************************



//*** FUNCION AUXILIAR PARA VERIFICAR LAS RESPUESTAS */
final dbhelper = DatabaseHelper();
void _viewAnswers() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<AnswersModel> resultados = await dbHelper.getAnswers();
    for (var resultado in resultados) {
      print('Respuesta: ${resultado.resRespuesta},FK_RBF_id: ${resultado.fkRbfId},FK_AGF_id: ${resultado.fkAgfId}, USER_id: ${resultado.userId},  RES_complemento: ${resultado.resComplemento},  RES_device_id: ${resultado.deviceId} ');
    }
}
void _queryDelR() async {
  await dbhelper.delRespuestas();
    // print(result);
}