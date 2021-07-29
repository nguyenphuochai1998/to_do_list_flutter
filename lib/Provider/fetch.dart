import 'package:flutter/widgets.dart';

class FetchException {
  FetchException({required this.exception, required this.message});

  final Exception exception;
  final String message;
}

class FetchError {
  FetchError({required this.httpStatus, required this.message});

  final int httpStatus;
  final String message;
}

class FetchState<TResponse, TParams> {
  FetchState(
      {this.loading,
      this.response,
      this.error,
      this.exception,
      required this.fetch});

  Function(TParams? params) fetch;
  bool? loading;
  TResponse? response;
  FetchError? error;
  FetchException? exception;
}

class Fetch<TResponse, TParams> extends StatefulWidget {
  Fetch(
      {Key? key,
      required this.request,
      required this.builder,
      this.params,
      this.lazy = false,
      this.onSuccess,
      this.onError})
      : super(key: key);

  final bool lazy;
  final Function(TParams? params) request;
  final Function(FetchState<TResponse, TParams> fetchState) builder;

  final TParams? params;
  final Function(TResponse? response)? onSuccess;
  final Function(FetchError? response)? onError;

  @override
  _FetchState createState() => _FetchState<TResponse, TParams>();
}

class _FetchState<TResponse, TParams> extends State<Fetch<TResponse, TParams>> {
  late FetchState<TResponse, TParams> _fetchState;

  @override
  void initState() {
    super.initState();

    _fetchState = FetchState(fetch: _request);

    if (!widget.lazy) {
      // chay khi lazy => ban dau no cu xoay mai thoi
      _request(null);
    }
  }

  _request(TParams? params) async {
    try {
     // ban dau cho xoay
      setState(() {
        _fetchState = FetchState(
            fetch: _request, response: _fetchState.response, loading: true);
      });
      // doi th ni get du lieu api xong
      var response = await widget.request(params ?? widget.params);

// chay qua day
      this.setState(() {
        // update lai du lieu de build
        _fetchState = FetchState(
          // _request
            fetch: _request, loading: false, response: response, error: null);
      });
// chi goi ra kho xong
      if (widget.onSuccess != null) {
        widget.onSuccess!(response);
      }
    } on FetchError catch (error) {
      this.setState(() {
        _fetchState = FetchState(
            fetch: _request,
            loading: false,
            response: _fetchState.response,
            error: error);
      });

      if (widget.onError != null) {
        widget.onError!(error);
      }
    } on Exception catch (exception) {
      this.setState(() {
        _fetchState = FetchState(
            fetch: _request,
            loading: false,
            response: _fetchState.response,
            exception: FetchException(
                exception: exception, message: exception.toString()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(_fetchState);
  }
}
