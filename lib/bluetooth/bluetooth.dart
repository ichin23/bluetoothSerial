import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Bluetooth with ChangeNotifier {
  BluetoothConnection? connection;
  String? id;
  BluetoothDevice? device;
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  bool loading = false;
  List<BluetoothDevice> bluetoothDevices = [];

  Future<List<BluetoothDevice>> getDevices() async {
    bluetoothDevices = await bluetoothSerial.getBondedDevices();
    print(bluetoothDevices);


    return bluetoothDevices;
  }

  void saveID(String newid) {
    id = newid;
    notifyListeners();
  }

  void saveDevice(BluetoothDevice newdevice) {
    device = newdevice;
    notifyListeners();
  }

  void saveConnection(BluetoothConnection newConnection) {
    connection = newConnection;
    notifyListeners();
  }

  void connect() async {
    if(device!=null){
    connection = await BluetoothConnection.toAddress(device!.address).then((value) {
      print(value.isConnected.toString());

    }).catchError((e){print(e);});}
    notifyListeners();
  }

  Uint8List encodeMessage(String enviar) {
    var utf = utf8.encode(enviar);
    var bytes = Uint8List.fromList(utf);
    return bytes;
  }

  setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  testConnect() async {
    await BluetoothConnection.toAddress(id).then((_connection) {
      print('Connected to the device');
      connection = _connection;

      connection!.input!.listen(null).onDone(() {
        if (!connection!.isConnected) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
  }

  sendMessage(String message, context) async {
    if (connection != null) {
      try {
        connection!.output.add(encodeMessage(message));
      } catch (e) {
        if (e.toString().contains('Not connected')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Nenhum dispositivo conectado'),
            ),
          );
        }
      }
    }
  }
}
