import 'dart:async';

import 'package:flib_lifecycle/flib_lifecycle.dart';

typedef FEventBusObserver<T> = void Function(T event);

class FEventBus {
  static FEventBus _instance;

  final StreamController _streamController;
  final Map<Function, _ObserverWrapper> _mapObserver = {};

  FEventBus._()
      : this._streamController = StreamController.broadcast(sync: true);

  static FEventBus get singleton {
    if (_instance == null) {
      _instance = FEventBus._();
    }
    return _instance;
  }

  /// 添加观察者
  ///
  /// - [T] 需要观察的事件类型
  /// - [observer] 观察者
  /// - [lifecycleOwner] 观察者要绑定的生命周期
  ///   1. [lifecycleOwner] != null，则[FLifecycleEvent.onDestroy]事件后，会自动移除观察者
  ///   2. [lifecycleOwner] == null，则不会自动移除观察者
  void addObserver<T>(
    FEventBusObserver<T> observer,
    FLifecycleOwner lifecycleOwner,
  ) {
    if (T == dynamic) {
      throw Exception('Generics "T" are not specified');
    }

    if (_mapObserver.containsKey(observer)) {
      return;
    }

    FLifecycle lifecycle;
    if (lifecycleOwner != null) {
      lifecycle = lifecycleOwner.getLifecycle();
      assert(lifecycle != null);
      if (lifecycle.getCurrentState() == FLifecycleState.destroyed) {
        return;
      }
    }

    final Stream<T> stream =
        _streamController.stream.where((event) => event is T).cast<T>();

    final _ObserverWrapper wrapper = _ObserverWrapper(
      observer: observer,
      canceller: stream.listen(observer),
      eventBus: this,
      lifecycle: lifecycle,
    );

    _mapObserver[observer] = wrapper;
  }

  /// 移除观察者
  void removeObserver(Function observer) {
    final _ObserverWrapper wrapper = _mapObserver.remove(observer);
    if (wrapper != null) {
      wrapper.destroy();
    }
  }

  /// 发送事件
  ///
  /// - [event] 要发送的事件
  void post(dynamic event) {
    _streamController.add(event);
  }
}

class _ObserverWrapper extends FLifecycleWrapper {
  final Function observer;
  final StreamSubscription canceller;
  final FEventBus eventBus;

  _ObserverWrapper({
    this.observer,
    this.canceller,
    this.eventBus,
    FLifecycle lifecycle,
  })  : assert(observer != null),
        assert(canceller != null),
        assert(eventBus != null),
        super(lifecycle);

  @override
  void onDestroy() {
    canceller.cancel();
    eventBus.removeObserver(observer);
  }
}
