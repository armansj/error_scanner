import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Chat',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";
  bool _isLoading = false;
  late IOWebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect('ws://127.0.0.1:8000/ws/ask/');
  }

  Future<void> sendMessage(String question) async {
    setState(() {
      _isLoading = true;
    });
    _channel.sink.add(question);
    _channel.stream.listen((message) {
      setState(() {
        _response = message;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your question',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  sendMessage(_controller.text.trim());
                }
              },
              child: Text('Send'),
            ),
            SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator()
                : Text(
              _response,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
