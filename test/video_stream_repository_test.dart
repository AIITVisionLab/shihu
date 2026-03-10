import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('VideoStreamRepository parses video stream list payload', () async {
    final repository = VideoStreamRepository(
      apiClient: _FakeVideoApiClient(
        jsonMap: <String, dynamic>{
          'code': 0,
          'msg': 'ok',
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'streamId': 'k230',
              'deviceId': 'k230',
              'displayName': 'K230 实时视频流',
              'gatewayPageUrl': 'http://101.35.79.76:1984/',
              'playerUrl':
                  'http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse',
              'preferredMode': 'webrtc',
              'fallbackMode': 'mse',
              'publicHost': '101.35.79.76',
              'webrtcPort': 8555,
              'available': true,
              'aiResultForwarded': false,
            },
          ],
        },
      ),
    );

    final streams = await repository.fetchStreams();

    expect(streams, hasLength(1));
    expect(streams.first.streamId, 'k230');
    expect(streams.first.available, isTrue);
    expect(streams.first.playbackModeLabel, 'webrtc / mse');
  });

  test('VideoStreamRepository rejects failed business status', () async {
    final repository = VideoStreamRepository(
      apiClient: _FakeVideoApiClient(
        jsonMap: <String, dynamic>{
          'code': 500,
          'msg': 'service down',
          'data': const <Object>[],
        },
      ),
    );

    await expectLater(
      repository.fetchStreams(),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'service down',
        ),
      ),
    );
  });
}

class _FakeVideoApiClient extends ApiClient {
  _FakeVideoApiClient({required this.jsonMap})
    : super(
        settings: AppSettings.defaults(
          buildFlavor: BuildFlavor.development,
          baseUrl: 'http://127.0.0.1:8080',
          enableLog: true,
        ),
        envConfig: const EnvConfig(
          flavor: BuildFlavor.development,
          baseUrl: 'http://127.0.0.1:8080',
          enableLog: true,
        ),
      );

  final Map<String, dynamic> jsonMap;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return jsonMap;
  }
}
