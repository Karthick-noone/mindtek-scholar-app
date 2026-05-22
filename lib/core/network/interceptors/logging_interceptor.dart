import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('╔══════════ REQUEST ══════════');
    print('METHOD: ${options.method}');
    print('BASE URL: ${options.baseUrl}');
    print('PATH: ${options.path}');
    print('FULL URL: ${options.uri}');
    print('HEADERS: ${options.headers}');
    print('QUERY PARAMS: ${options.queryParameters}');
    
    if (options.data != null) {
      print('BODY: ${options.data}');
    }

    print('═══════════════════════════════');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('╔══════════ RESPONSE ══════════');
    print('STATUS CODE: ${response.statusCode}');
    print('PATH: ${response.requestOptions.path}');
    print('FULL URL: ${response.requestOptions.uri}');
    
    print('HEADERS:');
    response.headers.forEach((key, value) {
      print('  $key: $value');
    });

    print('DATA: ${response.data}');
    print('═══════════════════════════════');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('╔══════════ ERROR ══════════');
    print('TYPE: ${err.type}');
    print('STATUS CODE: ${err.response?.statusCode}');
    print('METHOD: ${err.requestOptions.method}');
    print('PATH: ${err.requestOptions.path}');
    print('FULL URL: ${err.requestOptions.uri}');
    
    print('REQUEST HEADERS: ${err.requestOptions.headers}');
    print('REQUEST DATA: ${err.requestOptions.data}');

    if (err.response != null) {
      print('--- RESPONSE HEADERS ---');
      err.response!.headers.forEach((key, value) {
        print('  $key: $value');
      });

      print('--- RESPONSE DATA ---');
      print(err.response!.data);

      // 🔥 MOST IMPORTANT (redirect debug)
      print('--- REDIRECT LOCATION ---');
      print(err.response!.headers.value('location'));
    }

    print('ERROR MESSAGE: ${err.message}');
    print('═══════════════════════════════');

    handler.next(err);
  }
}