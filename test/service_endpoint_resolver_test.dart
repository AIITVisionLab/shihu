import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/service_endpoint_resolver.dart';

void main() {
  test('ServiceEndpointResolver keeps normalized device service url', () {
    final endpoints = ServiceEndpointResolver.resolve(
      configuredBaseUrl: ' http://101.35.79.76:8082/ ',
      fallbackBaseUrl: 'http://127.0.0.1:8082',
    );

    expect(endpoints.deviceBaseUrl, 'http://101.35.79.76:8082');
  });

  test('ServiceEndpointResolver falls back to env base url when invalid', () {
    final endpoints = ServiceEndpointResolver.resolve(
      configuredBaseUrl: 'not-a-url',
      fallbackBaseUrl: 'http://127.0.0.1:8082',
    );

    expect(endpoints.deviceBaseUrl, 'http://127.0.0.1:8082');
  });

  test('ServiceEndpointResolver rejects base urls with extra path', () {
    expect(
      ServiceEndpointResolver.normalizeBaseUrl('http://127.0.0.1:8082/api'),
      isNull,
    );
  });
}
