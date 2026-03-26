import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/service_config/domain/service_endpoint_resolver.dart';

void main() {
  test('ServiceEndpointResolver keeps normalized device service url', () {
    final endpoints = ServiceEndpointResolver.resolve(
      configuredBaseUrl: ' http://127.0.0.1:8085/ ',
      fallbackBaseUrl: 'http://127.0.0.1:8085',
    );

    expect(endpoints.deviceBaseUrl, 'http://127.0.0.1:8085');
  });

  test('ServiceEndpointResolver falls back to env base url when invalid', () {
    final endpoints = ServiceEndpointResolver.resolve(
      configuredBaseUrl: 'not-a-url',
      fallbackBaseUrl: 'http://127.0.0.1:8085',
    );

    expect(endpoints.deviceBaseUrl, 'http://127.0.0.1:8085');
  });

  test('ServiceEndpointResolver rejects base urls with extra path', () {
    expect(
      ServiceEndpointResolver.normalizeBaseUrl('http://127.0.0.1:8085/api'),
      isNull,
    );
  });
}
