import 'package:flutter_test/flutter_test.dart';
import 'package:shellafood_delivery/features/disbursement/domain/models/disbursement_report_model.dart';

/// D1: WithdrawMethod.fromJson must tolerate the shapes the API actually sends:
/// - method_fields can arrive as an ARRAY (not just an object) → must not crash
/// - is_default can arrive as bool OR int (Laravel casts tinyint → bool)
void main() {
  group('WithdrawMethod.fromJson', () {
    test('method_fields as ARRAY does not throw', () {
      final json = <String, dynamic>{
        'id': 1,
        'method_name': 'تحويل بنكي',
        'method_fields': [
          {'input_name': 'iban', 'value': 'SA0000'},
        ],
        'is_default': true,
      };
      final m = WithdrawMethod.fromJson(json);
      expect(m.id, 1);
      expect(m.methodName, 'تحويل بنكي');
      expect(m.isDefault, true);
    });

    test('method_fields as OBJECT parses transaction_id', () {
      final json = <String, dynamic>{
        'id': 2,
        'method_fields': {'transaction_id': 'TX9'},
        'is_default': false,
      };
      final m = WithdrawMethod.fromJson(json);
      expect(m.methodFields?.transactionId, 'TX9');
      expect(m.isDefault, false);
    });

    test('is_default accepts int 1 (bool/int safe)', () {
      final m = WithdrawMethod.fromJson(<String, dynamic>{'id': 3, 'is_default': 1});
      expect(m.isDefault, true);
    });
  });
}
