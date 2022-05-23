import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothserial/bluetooth/bluetooth.dart';

import 'package:bluetoothserial/screens/set_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Bluetooth(),
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primaryColor: Color(0xff0016A6),
            buttonTheme: ButtonThemeData(buttonColor: Color(0xff1DF2C7)),
          ),
          home: const MyHomePage(title: 'BluetoothSerial')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();
    Bluetooth bluetooth = Provider.of<Bluetooth>(context, listen: false);
    // Listen for further state changes
    bluetooth.bluetoothSerial.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        print(state.isEnabled);
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
      });
    });
  }

  @override
  void dispose() {
    Bluetooth bluetooth = Provider.of<Bluetooth>(context, listen: false);
    if (bluetooth.connection != null) {
      bluetooth.connection!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Bluetooth bluetooth = Provider.of<Bluetooth>(context);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xff000B15),
      appBar: AppBar(
          title: Text(bluetooth.connection != null
              ? bluetooth.connection!.isConnected
                  ? "Conected to ${bluetooth.device!.name}"
                  : "Bluetooth ON"
              : "Bluetooth"),
          backgroundColor: Color(0xff1835F2),
          actions: [
            IconButton(
                icon: Icon(Icons.bluetooth),
                onPressed: () async {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SetDevice()));
                })
          ]),
      body: SafeArea(
        child: StreamBuilder<BluetoothState>(
            stream: bluetooth.bluetoothSerial.onStateChanged(),
            builder: (context, snapshot) {
              if (snapshot.data != null &&
                  snapshot.data! == BluetoothState.STATE_ON) {
                return Stack(
                  children: [
                    Center(
                      child: Container(
                        width: width,
                        height: height * 0.3,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: width * 0.6,
                                height: 50,
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).primaryColor),
                                      textStyle: MaterialStateProperty.all(
                                          TextStyle(color: Colors.black))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wb_incandescent,
                                        color: Colors.yellow,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Ligar",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  onPressed: () {
                                    print('nada');
                                    if (bluetooth.connection != null) {
                                      try {
                                        bluetooth.connection!.output.add(
                                            bluetooth.encodeMessage('1\r\n'));
                                      } catch (e) {
                                        if (e
                                            .toString()
                                            .contains('Not connected')) {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                  'Nenhum dispositivo conectado'),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(e.toString()),
                                          ));
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                              Container(
                                width: width * 0.6,
                                height: 50,
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).primaryColor)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wb_incandescent_outlined,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 10),
                                      const Text("Desligar",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  onPressed: () {
                                    if (bluetooth.connection != null) {
                                      try {
                                        bluetooth.connection!.output.add(
                                            bluetooth.encodeMessage('2\r\n'));
                                      } catch (e) {
                                        if (e
                                            .toString()
                                            .contains('Not connected')) {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                  'Nenhum dispositivo conectado'),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(e.toString()),
                                          ));
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).primaryColor)),
                                child: const Text("Status"),
                                onPressed: () {
                                  if (bluetooth.connection != null) {
                                    print(bluetooth.connection!.isConnected
                                        .toString());
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(bluetooth
                                          .connection!.isConnected
                                          .toString()),
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('nada'),
                                    ));
                                  }
                                },
                              ),
                            ]),
                      ),
                    ),
                    bluetooth.connection != null
                        ? bluetooth.connection!.isConnected
                            ? Container()
                            : Container(
                                height: height,
                                width: width,
                                color: Colors.black.withOpacity(0.7),
                                child: Center(
                                    child: Text(
                                        "Conecte a um dispositivo Primeiro",
                                        style: TextStyle(color: Colors.white))),
                    )
                        : Container(
                        height: height,
                        width: width,
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                            child: Text(
                                "Conecte a um dispositivo Primeiro",
                                style: TextStyle(color: Colors.white))))
                  ],
                );
              } else {
                return Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_disabled,
                            size: 30, color: Colors.white),
                        Text("Bluetooth Desativado",
                            style: TextStyle(color: Colors.white)),
                        TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor)),
                            child: Text("Ligar Bluetooth"),
                            onPressed: () {
                              bluetooth.bluetoothSerial.requestEnable();
                            })
                      ]),
                );
              }
            }),
      ),
    );
  }
}
