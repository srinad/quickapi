// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quickapi/quickapi.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickApi Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ApiTestPage(),
    );
  }
}

class ApiTestPage extends StatefulWidget {
  @override
  _ApiTestPageState createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  late QuickApi _api;
  String _response = '';

  @override
  void initState() {
    super.initState();
    _api = QuickApi(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      logger: (message) => log('[QuickApi] $message'),
    );
  }

  void _testGet() async {
    setState(() {
      _response = 'Loading...';
    });

    try {
      final result = await _api.typeGet('/posts/1');
      setState(() {
        _response = 'GET Response: ${result.toString()}';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  void _testPost() async {
    setState(() {
      _response = 'Loading...';
    });

    // Define the parameters in a variable
    final params = {
      'title': 'New Post testing',
      'body': 'This is a new post.',
      'userId': 1,
    };

    try {
      // Pass the params variable to the API call
      final result = await _api.typePost('/posts', params);

      setState(() {
        _response = 'POST Response: ${result.toString()}';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  void _testPut() async {
    setState(() {
      _response = 'Loading...';
    });

    try {
      final result = await _api.typePut('/posts/1', {
        'title': 'Updated Post',
        'body': 'This is an updated post.',
        'userId': 1,
      });

      setState(() {
        _response = 'PUT Response: ${result.toString()}';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  void _testDelete() async {
    setState(() {
      _response = 'Loading...';
    });

    try {
      final result = await _api.typeDelete('/posts/1');
      setState(() {
        _response = 'DELETE Response: ${result.toString()}';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  void _testMultipartPost() async {
    setState(() {
      _response = 'Loading...';
    });

    try {
      final file = await _pickFile(); // Implement file picker
      if (file != null) {
        final result = await _api.typePostMultipart('/upload', {
          'description': 'Test File Upload'
        }, [
          http.MultipartFile.fromBytes('file', await file.readAsBytes(),
              filename: 'file.jpg')
        ]);
        setState(() {
          _response = 'Multipart POST Response: ${result.toString()}';
        });
      } else {
        setState(() {
          _response = 'No file selected';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  Future<File?> _pickFile() async {
    // Implement file picker logic here (using file_picker package)
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickApi Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _testGet,
              child: Text('Test GET Request'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _testPost,
              child: Text('Test POST Request'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _testPut,
              child: Text('Test PUT Request'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _testDelete,
              child: Text('Test DELETE Request'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _testMultipartPost,
              child: Text('Test Multipart POST (File Upload)'),
            ),
            SizedBox(height: 20),
            Text('Response:'),
            SizedBox(height: 10),
            Text(_response, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
