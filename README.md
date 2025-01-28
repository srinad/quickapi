# QuickApi

QuickApi is a lightweight and efficient API helper library for Flutter and Dart projects. It simplifies making HTTP requests with various methods like GET, POST, PUT, DELETE, and supports features like timeout handling, multipart file uploads, logging, and response caching.
![API Request](https://imgur.com/5hxxsZh)
![API Request](https://imgur.com/HaTtn2k)
![API Request](https://imgur.com/A1iR51W)

## Features

- **GET, POST, PUT, DELETE**: Easily make standard HTTP requests.
- **Timeout Handling**: Set timeouts for requests.
- **Multipart Uploads**: Upload files with additional data.
- **Logging Support**: Log requests and responses for debugging.
- **Retry Logic**: Automatically retry on network issues or transient errors.
- **Response Caching**: Cache responses to minimize API calls.
- **Custom Error Handling**: Handle specific errors like timeout or network failures.

## Installation

To use `quickapi` in your Flutter or Dart project, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  quickapi: ^1.0.0
