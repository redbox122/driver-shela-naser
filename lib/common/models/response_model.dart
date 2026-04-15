class ResponseModel {
  final bool _isSuccess;
  final String? _message;
  dynamic errorResponse; // Store full error response for detailed handling

  ResponseModel(this._isSuccess, this._message, [this.errorResponse]);

  String? get message => _message;
  bool get isSuccess => _isSuccess;
}
