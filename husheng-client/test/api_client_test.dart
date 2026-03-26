import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('ApiClient maps receive timeout to timeout ApiException', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    server.listen((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      try {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write('{"code":200,"message":"success","data":{}}');
        await request.response.close();
      } catch (_) {
        // 客户端超时后服务端写回会失败，这里直接忽略。
      }
    });

    final client = _buildClient(
      baseUrl: 'http://127.0.0.1:${server.port}',
      receiveTimeoutMs: 50,
    );

    await expectLater(
      client.getJson('/timeout'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.isTimeout, 'isTimeout', isTrue)
            .having((error) => error.message, 'message', '请求超时，请检查网络或服务地址。'),
      ),
    );
  });

  test(
    'ApiClient maps connection failure to connection ApiException',
    () async {
      final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = socket.port;
      await socket.close();

      final client = _buildClient(baseUrl: 'http://127.0.0.1:$port');

      await expectLater(
        client.getJson('/unreachable'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.isConnectionError,
                'isConnectionError',
                isTrue,
              )
              .having(
                (error) => error.message,
                'message',
                '网络连接失败，请检查网络或服务地址。',
              ),
        ),
      );
    },
  );

  test(
    'ApiClient maps empty server reply to backend response ApiException',
    () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);

      server.listen((socket) {
        socket.listen((_) {
          socket.destroy();
        });
      });

      final client = _buildClient(baseUrl: 'http://127.0.0.1:${server.port}');

      await expectLater(
        client.getJson('/empty-reply'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            '服务未返回有效响应，请检查后端服务状态。',
          ),
        ),
      );
    },
  );

  test(
    'ApiClient invokes unauthorized callback for HTTP 401 response',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final unauthorizedMessages = <String?>[];

      server.listen((request) async {
        request.response
          ..statusCode = HttpStatus.unauthorized
          ..headers.contentType = ContentType.json
          ..write('{"message":"unauthorized"}');
        await request.response.close();
      });

      final client = _buildClient(
        baseUrl: 'http://127.0.0.1:${server.port}',
        onUnauthorized: ({message}) {
          unauthorizedMessages.add(message);
        },
      );

      await expectLater(
        client.getJson('/unauthorized'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', 'unauthorized'),
        ),
      );

      expect(unauthorizedMessages, <String?>['unauthorized']);
    },
  );

  test('ApiClient keeps backend message for HTTP 400 response', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    server.listen((request) async {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.json
        ..write('{"status":"error","message":"deviceId不能为空"}');
      await request.response.close();
    });

    final client = _buildClient(baseUrl: 'http://127.0.0.1:${server.port}');

    await expectLater(
      client.postJson('/bad-request', data: <String, dynamic>{}),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'deviceId不能为空',
        ),
      ),
    );
  });

  test(
    'ApiClient invokes unauthorized callback for business code 40101',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final unauthorizedMessages = <String?>[];

      server.listen((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write('{"code":40101,"message":"token expired","data":null}');
        await request.response.close();
      });

      final client = _buildClient(
        baseUrl: 'http://127.0.0.1:${server.port}',
        onUnauthorized: ({message}) {
          unauthorizedMessages.add(message);
        },
      );

      final response = await client.getResponse<Map<String, dynamic>>(
        '/business-unauthorized',
        dataParser: (data) => data is Map<String, dynamic> ? data : null,
      );

      expect(response.code, 40101);
      expect(response.isSuccess, isFalse);
      expect(unauthorizedMessages, <String?>['token expired']);
    },
  );
}

ApiClient _buildClient({
  required String baseUrl,
  int receiveTimeoutMs = 500,
  void Function({String? message})? onUnauthorized,
}) {
  return ApiClient(
    settings: AppSettings.defaults(
      buildFlavor: BuildFlavor.development,
      baseUrl: baseUrl,
      enableLog: true,
    ).copyWith(connectTimeoutMs: 500, receiveTimeoutMs: receiveTimeoutMs),
    envConfig: EnvConfig(
      flavor: BuildFlavor.development,
      baseUrl: baseUrl,
      enableLog: true,
    ),
    onUnauthorized: onUnauthorized,
  );
}
