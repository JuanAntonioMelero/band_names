import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 10),
    // Band(id: '3', name: 'Heroes del silencio', votes: 3),
    // Band(id: '4', name: 'Bon Jovi', votes: 8),
  ];

  @override
  void initState() {
    //cargamos las bandas nada mas empezar
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('bandas activas', (payload) {
      //cargamos la lista como un mapeo del payload.
      bands = (payload as List).map((band) => Band.fromMap(band)).toList();

      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    //cerramos la escucha.
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bandas activas');
    super.dispose();
  }

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

      body: Column(
        children: <Widget>[
          //añadimos metodo widget de la grafica
          Container(
            padding: EdgeInsets.only(top: 20, left: 20, ),
            child: _showGraph(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) =>
                  _bandTile(bands[index]),
            ),
          ),
        ],
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
    final socketService = Provider.of<SocketService>(context, listen: false);

    //dismissible es para eliminar elemento de la lista deslizando sobre el
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        socketService.socket.emit('delete-band', {'id': band.id});
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
          //band.votes++;
          socketService.socket.emit('vote-band', {'id': band.id});
          setState(() {});
          print('${band.id}${band.votes}');
        },
      ),
    );
  }

  //mostrar grafica
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    //dataMap.putIfAbsent('Flutter', () => 5);
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    return PieChart(dataMap: dataMap, chartType: ChartType.ring);
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      //podemos agregar
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context); //esto cierra  el alertDialog
  }
}
