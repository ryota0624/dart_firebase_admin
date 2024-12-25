import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

import 'util/helpers.dart';

void main() {
  group('Transaction', () {
    late Firestore firestore;

    setUp(() => firestore = createFirestore());

    test('runTransaction', () async {
      await firestore.runTransaction((tx) async {
        final a = firestore.collection('a');
        tx.create(a.doc('1'), {'a': 1});
      });
      {
        final a = await firestore.collection('a').doc('1').get();
        expect(a.data(), {'a': 1});
      }

      await firestore.runTransaction((tx) async {
        final ref = firestore.collection('a').doc('1');
        final a = await ref.get(tx: tx);
        tx.set(ref, {...a.data() ?? {}, 'b': 2});
      });
      {
        final a = await firestore.collection('a').doc('1').get();
        expect(a.data(), {'a': 1, 'b': 2});
      }
    });
  });
}
