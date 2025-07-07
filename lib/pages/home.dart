import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 10),
    Band(id: '3', name: 'Heroes del silencio', votes: 3),
    Band(id: '4', name: 'Bon Jovi', votes: 8),
  ];

  @override
  Widget build(BuildContext context) {

    //cargamos el estado de la conexion
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('BandNames', style: TextStyle(color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            //creamos condicionante para segun el estado de la conexion
            child: (socketService.serverStatus == ServerStatus.Offline)
                ? Icon(Icons.offline_bolt, color: Colors.red)
                : Icon(Icons.check_circle, color: Colors.green),
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) =>
            _bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: Icon(Icons.add), //para que no tenga tanta sombra
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('NexBandNAme'),
            content: TextField(
              controller:
                  textController, //se le asigna la variable creada como TextEditingController
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () {
                  addBandToList(textController.text);
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _bandTile(Band band) {
    //dismissible es para eliminar elemento de la lista deslizando sobre el
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        print('direction: $direction');
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Eliminar Banda', style: TextStyle(color: Colors.white)),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            band.name.substring(0, 2),
          ), // necesitamos solo las dos primeras letras del nombre
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () {
          band.votes++;
          setState(() {});
          print('${band.name}${band.votes}');
        },
      ),
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      //podemos agregar
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {}); //actualizar datos
    }

    Navigator.pop(context); //esto cierra  el alertDialog
  }
}
