import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/handles/domain/entities/stray_handle_endpoint_kind.dart';

void main() {
  group('classifyStrayHandleEndpoint', () {
    test('classifies full telephone endpoints as phone numbers', () {
      expect(
        classifyStrayHandleEndpoint('+1 (604) 685-8506'),
        StrayHandleEndpointKind.phoneNumber,
      );
      expect(
        classifyStrayHandleEndpoint('tel:+16046858506'),
        StrayHandleEndpointKind.phoneNumber,
      );
    });

    test('classifies numeric short codes without assigning intent', () {
      expect(
        classifyStrayHandleEndpoint('74720'),
        StrayHandleEndpointKind.shortCode,
      );
    });

    test('classifies email and business endpoints', () {
      expect(
        classifyStrayHandleEndpoint('person@example.com'),
        StrayHandleEndpointKind.emailAddress,
      );
      expect(
        classifyStrayHandleEndpoint('urn:biz:messages:example'),
        StrayHandleEndpointKind.businessUrn,
      );
    });

    test('preserves unrecognized endpoint forms as other', () {
      expect(
        classifyStrayHandleEndpoint('opaque-source'),
        StrayHandleEndpointKind.other,
      );
    });
  });
}
