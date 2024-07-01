import 'dart:isolate';
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Isolate Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = "Result will be shown here";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Isolate Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _result,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runIsolate,
              child: Text('Run Heavy Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runIsolate() async {
    // Create a ReceivePort for communication with the isolate
    final receivePort = ReceivePort();

    // Spawn an isolate and pass the SendPort
    await Isolate.spawn(_heavyTask, receivePort.sendPort);

    // Receive data from the isolate
    final result = await receivePort.first;

    setState(() {
      _result = result.toString();
    });
  }

  static void _heavyTask(SendPort sendPort) {
    // Simulate a heavy task
    int sum = 0;
    for (int i = 0; i < 1000000000; i++) {
      sum += i;
    }

    // Send the result back to the main isolate
    sendPort.send(sum);
  }
}
