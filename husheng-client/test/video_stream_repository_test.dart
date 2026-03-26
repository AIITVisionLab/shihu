import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('VideoStreamRepository parses stream list from backend payload', () async {
    final apiClient = _FakeApiClient(
      rawResponse: <String, dynamic>{
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
    );
    final repository = _buildRepository(apiClient);

    final streams = await repository.fetchStreams();

    expect(apiClient.capturedPath, '/api/video/streams');
    expect(streams, hasLength(1));
    expect(streams.first.streamId, 'k230');
    expect(streams.first.playerUrl, contains('stream.html?src=k230'));
  });

  test(
    'VideoStreamRepository falls back to configured gateway when backend video endpoint is missing',
    () async {
      final apiClient = _FakeApiClient(
        rawException: const ApiException(
          statusCode: 500,
          message: 'No static resource api/video/streams.',
        ),
      );
      final repository = _buildRepository(apiClient);

      final streams = await repository.fetchStreams();

      expect(streams, hasLength(1));
      expect(streams.first.streamId, 'k230');
      expect(streams.first.gatewayPageUrl, 'http://101.35.79.76:1984/');
      expect(
        streams.first.playerUrl,
        'http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc%2Cmse',
      );
      expect(streams.first.available, isTrue);
      expect(streams.first.webrtcPort, 8555);
    },
  );

  test(
    'VideoStreamRepository rethrows unrelated backend errors without using gateway fallback',
    () async {
      final repository = _buildRepository(
        _FakeApiClient(
          rawException: const ApiException(
            statusCode: 500,
            message: '视频服务内部错误。',
          ),
        ),
      );

      await expectLater(
        repository.fetchStreams(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            '视频服务内部错误。',
          ),
        ),
      );
    },
  );
}

VideoStreamRepository _buildRepository(ApiClient apiClient) {
  return VideoStreamRepository(
    apiClient: apiClient,
    fallbackGatewayUrl: 'http://101.35.79.76:1984',
    fallbackStreamId: 'k230',
    fallbackDisplayName: 'K230 实时视频流',
    fallbackPreferredMode: 'webrtc',
    fallbackMode: 'mse',
    fallbackWebrtcPort: 8555,
  );
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    this.rawResponse,
    this.rawException,
    String baseUrl = 'http://127.0.0.1:8085',
  }) : super(
         settings: AppSettings.defaults(
           buildFlavor: BuildFlavor.development,
           baseUrl: baseUrl,
           enableLog: true,
         ),
         envConfig: EnvConfig(
           flavor: BuildFlavor.development,
           baseUrl: baseUrl,
           enableLog: true,
         ),
       );

  final Object? rawResponse;
  final ApiException? rawException;
  String? capturedPath;

  @override
  Future<Object?> getRaw(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    capturedPath = path;
    if (rawException != null) {
      throw rawException!;
    }
    return rawResponse;
  }
}
