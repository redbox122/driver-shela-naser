class ResponseModel {
  final bool _isSuccess;
  final String? _message;
  dynamic _errorResponse; // Store full error response for detailed handling

  ResponseModel(this._isSuccess, this._message, [this._errorResponse]);

  String? get message => _message;
  bool get isSuccess => _isSuccess;
  dynamic get errorResponse => _errorResponse;

  /// Set error response for detailed error handling
  set errorResponse(dynamic response) => _errorResponse = response;
}
