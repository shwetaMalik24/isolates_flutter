import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Isolate Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _result = 0;
  bool _isCalculating = false;

  Future<void> _calculateFibonacci(int n) async {
    setState(() {
      _isCalculating = true;
    });

    // Create a ReceivePort to receive messages from the isolate
    final receivePort = ReceivePort();

    // Spawn the isolate
    await Isolate.spawn(calculateFibonacci, receivePort.sendPort);

    // Receive results from the isolate
    final sendPort = await receivePort.first as SendPort;
    final answer = ReceivePort();
    sendPort.send([n, answer.sendPort]);

    // Wait for the result from the isolate
    final result = await answer.first;

    // Update the state outside of setState()
    setState(() {
      _result = result;
      _isCalculating = false;
    });
  }

  static void calculateFibonacci(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    port.listen((message) {
      final data = message[0] as int;
      final replyTo = message[1] as SendPort;

      // Perform heavy computation in the isolate
      replyTo.send(fibonacci(data));
    });
  }

  static int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Isolate Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isCalculating)
              CircularProgressIndicator()
            else
              Text(
                'Fibonacci Result: $_result',
                style: TextStyle(fontSize: 24),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _calculateFibonacci(3), // Example n value
              child: Text('Calculate Fibonacci'),
            ),
          ],
        ),
      ),
    );
  }
}
