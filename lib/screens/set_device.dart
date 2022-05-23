import '../bluetooth/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';

class SetDevice extends StatefulWidget {
  const SetDevice({Key? key}) : super(key: key);

  @override
  _SetDeviceState createState() => _SetDeviceState();
}

class _SetDeviceState extends State<SetDevice> {
  late Bluetooth bluetooth;

  @override
  void initState() {
    Provider.of<Bluetooth>(context, listen: false).setLoading(false);

    super.initState();
  }

  @override
  void dispose() {
    Provider.of<Bluetooth>(context, listen: false).dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bluetooth = Provider.of<Bluetooth>(context);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xff000B15),
      appBar: AppBar(
        title: Text('Escolher Dispositivo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Text("Selecione um dispositivo",
                  style: TextStyle(color: Colors.white)),
              Container(
                  height: 300,
                  child: FutureBuilder<List<BluetoothDevice>>(
                      future: Provider.of<Bluetooth>(context, listen: false)
                          .getDevices(),
                      builder: (context, snap) {
                        List<BluetoothDevice> dispositivos = [];

                        if (snap.connectionState == ConnectionState.done) {
                          BluetoothDevice? device;
                          return ListView.builder(
                              itemCount: snap.data!.length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  title: Text(snap.data![i].name!,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  subtitle: Text(snap.data![i].address,
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () async {
                                    print(snap.data![i].address);
                                    device = snap.data![i];
                                    bluetooth.saveDevice(device!);
                                    if (bluetooth.saveDevice != null) {
                                      bluetooth.setLoading(true);
                                      await BluetoothConnection.toAddress(
                                              bluetooth.device!.address)
                                          .then((value) {
                                        if (value.isConnected) {
                                          print('conectado');

                                          bluetooth.connection = value;
                                        } else {
                                          bluetooth.setLoading(false);

                                          print(value.isConnected.toString());
                                        }
                                      }).catchError((e) {
                                        bluetooth.setLoading(false);

                                        print(e);
                                      });
                                      //bluetooth.connect();
                                      /*await BluetoothConnection.toAddress(
                                              bluetooth.device!.address)
                                          .then((value) {
                                        if (value.isConnected) {
                                          print('conectado');
                                          bluetooth.connection = value;
                                        } else {
                                          print(value.isConnected.toString());
                                        }
                                      }).catchError((e){print(e);});*/
                                      bluetooth.setLoading(false);
                                    }
                                  },
                                );
                              });
                        } else {
                          return CircularProgressIndicator.adaptive();
                        }
                      })),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor)),
                  child: Text("Adicionar outro dispositivo"),
                  onPressed: () {
                    bluetooth.bluetoothSerial.openSettings();
                  })
            ],
          ),
          bluetooth.loading
              ? Container(
                  width: width,
                  height: height,
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                      child: Container(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator.adaptive())),
                )
              : Container(),
        ],
      ),
    );
  }
}
