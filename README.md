# About

一个用来管理事件通信的库，支持观察者监听生命周期，当生命周期销毁后自动移除观察者

## Install
* git
```
  flib_event_bus:
    git:
      url: git://github.com/zj565061763/flib_event_bus
      ref: 1.0.0
```

* pub
```
  dependencies:
    flib_event_bus: ^1.0.0
```

## Example
```dart
// 发送事件
FEventBus.singleton.post(ELoginSuccess());

// 监听事件
FEventBus.singleton.addObserver<ELoginSuccess>((event) {}, this);
```

```dart
/// 发送事件
///
/// - [event] 要发送的事件
void post(dynamic event)
```

```dart
/// 添加观察者
///
/// - [T] 需要观察的事件类型
/// - [observer] 观察者
/// - [lifecycleOwner] 观察者要绑定的生命周期
///   1. [lifecycleOwner] != null，则[FLifecycleEvent.onDestroy]事件后，会自动移除观察者
///   2. [lifecycleOwner] == null，则不会自动移除观察者
void addObserver<T>(FEventBusObserver<T> observer, FLifecycleOwner lifecycleOwner)

/// 移除观察者
void removeObserver(Function observer)
```