import 'package:date_time_picker/date_time_picker.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:light/light.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DateTimePicker Demo',
      home: MyHomePage(),
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', 'US')],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  late TextEditingController _controller4;
  String _valueChanged4 = '';
  String _valueToValidate4 = '';
  String _valueSaved4 = '';
  String _currentTime = '';
  String _luxString = 'Unknown';
  String clk = '';
  late Light _light;
  late StreamSubscription _subscription;
  var wakeup = 0;
  Color bgColor = Color.fromRGBO(125, 125, 125, 125);
  bool sign = true;
  AudioPlayer audioPlayer = AudioPlayer();

  void onData(int luxValue) async {
    Color bgColor_temp;
    if (luxValue <= 150) {
      bgColor_temp = Color.fromRGBO(125, 125, 125, 25);
    } else {
      bgColor_temp = Color.fromRGBO(255, 255, 255, 2);
    }
    if (luxValue >= 100) {
      //await TorchLight.disableTorch();
      await audioPlayer.release();
      wakeup = 0;
    }
    setState(() {
      _luxString = "$luxValue";
      bgColor = bgColor_temp;
    });
  }

  void stopListening() {
    _subscription.cancel();
  }

  void startListening() {
    _light = new Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    Intl.defaultLocale = 'pt_BR';
    String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');
    _controller4 = TextEditingController(text: '$lsHour:$lsMinute');
    _getValue();
  }

  Future<void> initPlatformState() async {
    startListening();
  }

  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _controller4.text = '17:01';
      });
    });
  }

  void _countdown() {
    audioPlayer.setSourceAsset("Radar.mp3");
    new Timer.periodic(const Duration(seconds: 1), (timer) {
      String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
      String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');
      String lsSecond = DateTime.now().second.toString().padLeft(2, '0');
      _controller4 = TextEditingController(text: '$lsHour:$lsMinute');
      setState(() {
        _currentTime = '$lsHour:$lsMinute:$lsSecond';
      });
      if ('$lsHour:$lsMinute' == _valueSaved4) {
        wakeup = 1;
        audioPlayer.setReleaseMode(ReleaseMode.loop);
        audioPlayer.play(AssetSource("Radar.mp3"));
        //TorchLight.enableTorch();
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Light Clock'),
          centerTitle: true,
        ),
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20, right: 20, top: 50),
          child: Form(
            key: _oFormKey,
            child: Column(
              children: <Widget>[
                DateTimePicker(
                  type: DateTimePickerType.time,
                  initialValue: '',
                  icon: Icon(Icons.access_time),
                  timeLabelText: "Time",
                  use24HourFormat: true,
                  locale: Locale('pt', 'BR'),
                  onChanged: (val) => setState(() => _valueChanged4 = val),
                  validator: (val) {
                    setState(() => _valueToValidate4 = val ?? '');
                    return null;
                  },
                  onSaved: (val) => setState(() => _valueSaved4 = val ?? ''),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    final loForm = _oFormKey.currentState;
                    if (loForm?.validate() == true) {
                      loForm?.save();
                    }
                  },
                  child: Text('Submit'),
                ),
                Text('Lux value: $_luxString\n'),
                Text('Alarm: $_valueSaved4\n'),
                Text("Now:" + _currentTime),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _countdown();
          },
          tooltip: 'Alarm',
          child: const Icon(Icons.alarm_on_sharp),
        ),
      ),
    );
  }
}
