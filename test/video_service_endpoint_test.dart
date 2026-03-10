import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/video_service_endpoint.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';

void main() {
  test(
    'VideoServiceEndpoint replaces service port with video service port',
    () {
      final resolved = VideoServiceEndpoint.resolveBaseUrl(
        'http://101.35.79.76:8082',
      );

      expect(resolved, AppConstants.defaultVideoBaseUrl);
    },
  );

  test('VideoServiceEndpoint falls back when base url is invalid', () {
    final resolved = VideoServiceEndpoint.resolveBaseUrl('not-a-url');

    expect(resolved, AppConstants.defaultVideoBaseUrl);
  });

  test('VideoServiceEndpoint resolves single stream url', () {
    final resolved = VideoServiceEndpoint.resolveStreamUrl(
      'http://10.0.0.1:8082',
      'k230',
    );

    expect(resolved, 'http://10.0.0.1:19081/api/video/streams/k230');
  });
}
