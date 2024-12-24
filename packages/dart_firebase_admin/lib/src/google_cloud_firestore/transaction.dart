part of 'firestore.dart';

class ReadOptions {
  ReadOptions({this.fieldMask});

  /// Specifies the set of fields to return and reduces the amount of data
  /// transmitted by the backend.
  ///
  /// Adding a field mask does not filter results. Documents do not need to
  /// contain values for all the fields in the mask to be part of the result
  /// set.
  final List<FieldMask>? fieldMask;
}

List<FieldPath>? _parseFieldMask(ReadOptions? readOptions) {
  return readOptions?.fieldMask?.map(FieldPath.fromArgument).toList();
}

class Transaction {
  Transaction(this.firestore, this.transactionId)
      : _writeBatch = WriteBatch._(firestore);

  final Firestore firestore;
  final String transactionId;

  final WriteBatch _writeBatch;

  void delete<T extends DocumentData>(DocumentReference<T> ref) {
    _writeBatch.delete(ref);
  }

  void set<T extends DocumentData>(
    DocumentReference<T> ref,
    T data,
  ) {
    _writeBatch.set(ref, data);
  }

  void update(
    DocumentReference<Object?> ref,
    UpdateMap data, {
    Precondition? precondition,
  }) {
    _writeBatch.update(ref, data, precondition: precondition);
  }

  Future<List<WriteResult>> commit() async {
    return _writeBatch.commit(
      transactionId: transactionId,
    );
  }

  Future<void> rollback() {
    return firestore._client.v1((client) async {
      await client.projects.databases.documents.rollback(
        firestore1.RollbackRequest(
          transaction: transactionId,
        ),
        firestore._formattedDatabaseName,
      );
    });
  }

  void create<T extends DocumentData>(
    DocumentReference<T> ref,
    T data,
  ) {
    _writeBatch.create(ref, data);
  }
}
