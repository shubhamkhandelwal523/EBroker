import 'dart:async';
import 'dart:isolate';

abstract class Task<T> {
  FutureOr<T> process();
}

class ProcessQueue {
  static final ProcessQueue _instance = ProcessQueue._internal();

  factory ProcessQueue() {
    return _instance;
  }

  ProcessQueue._internal();

  final List<Isolate> _isolates = [];
  final List<ReceivePort> _receivePorts = [];
  static Map<int, Completer<dynamic>> _taskCompleters = {};
  int _nextIsolateIndex = 0;

  Future<void> startIsolates(int numberOfIsolates) async {
    for (var i = 0; i < numberOfIsolates; i++) {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(_isolateWorker, receivePort.sendPort);
      _isolates.add(isolate);
      _receivePorts.add(receivePort);
    }
    await Future.delayed(Duration(milliseconds: 100));
  }

  void stopIsolates() {
    for (var i = 0; i < _isolates.length; i++) {
      _receivePorts[i].close();
      _isolates[i].kill(priority: Isolate.immediate);
    }
    _isolates.clear();
    _receivePorts.clear();
    _taskCompleters.clear();
    _nextIsolateIndex = 0;
  }

  static void _isolateWorker(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic data) async {
      final taskId = data['taskId'] as int;
      final task = data['task'] as Task;
      final mainSendPort = data['mainSendPort'] as SendPort;

      try {
        // final result = await task.process();

        // var x = await _taskCompleters[taskId]?.future;

        mainSendPort.send({'taskId': taskId, 'result': 0});
      } catch (e) {
        mainSendPort.send({'taskId': taskId, 'error': e.toString()});
      }
    });
  }

  Future<int> enqueueTask(Task task) async {
    if (_isolates.isEmpty) {
      throw StateError('No isolates running');
    }
    final taskId = _nextIsolateIndex++;
    final isolateIndex = taskId % _isolates.length;
    final sendPort = _receivePorts[isolateIndex].sendPort;

    final completer = Completer<dynamic>();
    _taskCompleters[taskId] = completer;
    _taskCompleters[taskId]?.complete(task.process());

    sendPort.send({
      'taskId': taskId,
      'task': task,
      'mainSendPort': ReceivePort().sendPort,
    });

    return taskId;
  }

  Future<dynamic> getResult(int taskId) async {
    if (taskId < 0 || taskId >= _nextIsolateIndex) {
      throw ArgumentError('Invalid taskId');
    }
    final completer = _taskCompleters[taskId];
    if (completer == null) {
      throw StateError('Completer for taskId $taskId not found');
    }

    return completer.future;
  }
}
