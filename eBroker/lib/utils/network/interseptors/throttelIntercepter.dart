import 'package:dio/dio.dart';

///In case there is rapidly API call request.. this will stop them
class ThrottleInterceptor extends Interceptor {
  // Map to store the last request timestamp for each API endpoint
  final Map<String, DateTime> _lastRequestTimestamps = {};

  // Minimum time interval between requests (in milliseconds)
  final int minInterval;

  ThrottleInterceptor({required this.minInterval});

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Get the key for the current API endpoint (you can customize this based on your needs)
    String apiEndpointKey = options.path;

    // Check if the last request for this API endpoint was made within the specified interval
    if (_isRequestThrottled(apiEndpointKey)) {
      // Do not proceed with the request
      handler.reject(DioException(
        requestOptions: options,
        error:
            'Request throttled. Please wait before making another request. $apiEndpointKey',
      ));
      return;
    }

    // Store the current timestamp for this API endpoint
    _lastRequestTimestamps[apiEndpointKey] = DateTime.now();

    // Proceed with the request
    handler.next(options);
  }

  bool _isRequestThrottled(String apiEndpointKey) {
    if (_lastRequestTimestamps.containsKey(apiEndpointKey)) {
      DateTime lastRequestTime = _lastRequestTimestamps[apiEndpointKey]!;
      DateTime currentTime = DateTime.now();
      int elapsedTime = currentTime.difference(lastRequestTime).inMilliseconds;
      print("Elapsed time is $lastRequestTime $elapsedTime");
      // Check if the elapsed time is less than the minimum interval
      return elapsedTime < minInterval;
    }

    // No previous request for this API endpoint
    return false;
  }
}
