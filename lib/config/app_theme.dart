import 'package:flutter/material.dart';

const colorList=<Color>[
  Colors.white,
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.purple,
  Colors.blue
];

//CLASE
class AppTheme{
  //VARIABLE
  final int selectedColor;

  //Constructor de la variable
  AppTheme({
    this.selectedColor = 0
    //el assert es una validacion
  }):assert( selectedColor >= 0, 'El color debe ser mayor a 0' ),
  assert( selectedColor < colorList.length, 'El color debe ser menor o igual a ${ colorList.length -1}' );

  //metdodo
  ThemeData getTheme()=> ThemeData(
    useMaterial3: true,
    //se configura el estilo de tema de la app segun el indice escogido
    colorSchemeSeed: colorList[selectedColor],
    appBarTheme: const AppBarTheme(
      centerTitle: true
    )
  );
  


}