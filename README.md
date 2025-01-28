# QuickApi

QuickApi is a powerful and easy-to-use Flutter dependency for seamless API integrations. 

---

## Features

- Effortless API handling.
- Customizable request headers.
- Retry mechanism for failed requests.
- Built-in logging for debugging.
- Easy parsing of JSON responses.

---

## Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  quick_api: latest_version
```

---

## Usage

### Full Example

Below is a complete example demonstrating how to use QuickApi in a Flutter application.

---

### 1. Import Dependencies

```dart
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quickapi/quickapi.dart';
import 'package:http/http.dart' as http;
```

---

### 2. Initialize QuickApi

```dart
class _ApiTestPageState extends State<ApiTestPage> {
  late QuickApi _api;

  @override
  void initState() {
    super.initState();
    _api = QuickApi(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      logger: (message) => log('[QuickApi] $message'),
    );
  }
}
```

---

### 3. Make API Calls

#### GET Request

```dart
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
```

#### POST Request

```dart
void _testPost() async {
  setState(() {
    _response = 'Loading...';
  });

  final params = {
    'title': 'New Post testing',
    'body': 'This is a new post.',
    'userId': 1,
  };

  try {
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
```

#### PUT Request

```dart
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
```

#### DELETE Request

```dart
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
```

#### Multipart POST Request

```dart
void _testMultipartPost() async {
  setState(() {
    _response = 'Loading...';
  });

  try {
    final file = await _pickFile();
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
```

---

### 4. Build the UI

```dart
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
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _testPost,
            child: Text('Test POST Request'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _testPut,
            child: Text('Test PUT Request'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _testDelete,
            child: Text('Test DELETE Request'),
          ),
          SizedBox(height: 10),
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
```