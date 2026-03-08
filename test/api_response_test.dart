import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/network/api_response.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

void main() {
  test('ApiResponse parses wrapped success payload', () {
    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      <String, dynamic>{
        'code': 200,
        'message': 'success',
        'data': <String, dynamic>{'detectId': 'det_1'},
      },
      dataParser: asStringMap,
    );

    expect(response.code, 200);
    expect(response.message, 'success');
    expect(response.isSuccess, isTrue);
    expect(response.data?['detectId'], 'det_1');
  });

  test('ApiResponse keeps null data when payload is absent', () {
    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      <String, dynamic>{
        'code': 50001,
        'message': 'inference failed',
        'data': null,
      },
      dataParser: asStringMap,
    );

    expect(response.code, 50001);
    expect(response.isSuccess, isFalse);
    expect(response.data, isNull);
  });
}
