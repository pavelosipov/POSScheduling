POSSchedulableObject
====================
[![Version](http://img.shields.io/cocoapods/v/POSSchedulableObject.svg)](http://cocoapods.org/?q=POSSchedulableObject)

Библиотека POSSchedulableObject являет собой пример реализации одноименного паттерна.
В таблице ниже приведено соответствие компонентов паттерна и реализующих их механизмов.

| Компонент              | Реализация                                                       |
| :--------------------- |:-----------------------------------------------------------------|
| События                | Блоки Objective-C                                                |
| Очередь событий        | Внутренняя реализация dispatch_queue_t из Grand Central Dispatch |
| Цикл обработки событий | Внутренняя реализация dispatch_queue_t из Grand Central Dispatch |
| Поток                  | Внутренняя реализация dispatch_queue_t из Grand Central Dispatch |
| Планировщик            | RACTargetQueueScheduler из ReactiveCocoa                         |

Центральная часть библиотеки – класс `POSSchedulableObject`. Будучи базовым классом для управляемых
объектов, он берет на себя следующие обязанности:

1. Имеет ссылку на планировщик, через который должно происходить косвенное взаимодействие с объектом.
2. Автоматически проверяет корректность потока, из которого происходит вызов методов объекта-наследника.
Достигается это за счет навешивания хуков (hooks) на все его методы в момент инициализации. В виду
дороговизны данной процедуры по умолчанию она осуществляется только в отладочной версии приложения.


Основную часть исходников репозитория составляет демо-приложение. Оно авторизует пользователя в сервисе
Dropbox, после чего выводит на экран имя и фамилию из его профиля. Рассмотрим несколько образцово-показательных
примеров использования им библиотеки POSSchedulableObject.

###Объявление класса

```objective-c
/// Providers info about account.
@protocol SODAccountInfoProvider <POSSchedulable>
/// @return Signal of nonnull SODAccountInfo.
- (RACSignal *)fetchAccountInfo;
@end

@interface SODDropboxAccountInfoProvider
    : POSSchedulableObject <SODAccountInfoProvider>
// ...
@end
```

Протокол `POSSchedulable` содержит методы для отправки событий управляемому объекту, обрабатывающихся
в другом потоке.

```objective-c
@protocol POSSchedulable <NSObject>
/// Scheduler which is used to perform calls to objects of that class.
@property (nonatomic, readonly) RACTargetQueueScheduler *scheduler;
/// @return Signal with this nonnull object delivered in the object's scheduler.
- (RACSignal *)schedule;
/// Schedules that object in the object's scheduler.
- (void)scheduleBlock:(void (^)(id schedulable))block;
@end
```

Класс `POSSchedulableObject` полностью реализует одноименный протокол. Кроме того, он добавляет проверки
на предмет того, что методы объекта вызываются в правильном потоке. Из проверок исключаются свойства с
атрибутом atomic. Для ручного исключения тех или иных методов существует специальный инициализатор с
настройками исключений.

```objective-c
@interface POSSchedulableObject : NSObject <POSSchedulable>

/// Schedules object inside main thread scheduler.
- (instancetype)init;

/// Schedules object inside specified scheduler.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler;

/// Schedules object inside specified scheduler with custom excludes.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                          options:(nullable POSScheduleProtectionOptions *)options;

// ...
@end
```

###Взаимодействие с классом

Листинг ниже показывает, как получить результат косвенного вызова и воспользоваться им в контексте потока
вызвавшего его объекта.

```objective-c
@implementation SODSettingsViewController
// ...
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[[[[_assembly.accountInfoProvider schedule]
      flattenMap:^RACStream *(id<SODAccountInfoProvider> provider) {
          return [provider fetchAccountInfo];
      }]
      deliverOnMainThread]
      takeUntil:self.rac_willDeallocSignal]
      subscribeNext:^(SODAccountInfo *accountInfo) {
          self.nameLabel.text = accountInfo.displayName;
      } error:^(NSError *error) {
          self.nameLabel.text = error.localizedDescription;
      }];
}
// ...
@end
```

Обращение к сервису `provider` путем отправки ему сообщения с использованием его планировщика. Далее результат
или ошибка перенаправляется обратно в главный цикл приложения.

###Сборка классов

Все объекты бизнес-логики приложения создаются внутри специальных классов, реализующих паттерн Dependency
Injection Container. По аналогии с популярной библиотекой <a href="https://github.com/appsquickly/Typhoon">Typhoon</a>,
в названиях таких классов фигурирует корень Assembly. Создание объектов внутри них имеет две особенности:

1. Объекты создаются лениво, по запросу. Следствием этого является изменяющееся на протяжении времени жизни
состояние объектов Assembly. Оно также защищается от многопоточного доступа путем наследования от
`POSSchedulableObject`.
2. Возврат объектов попросившей их стороне происходит синхронно во избежании большого количества клиентского
boilerplate-кода. Как видно из предыдущего листинга, использование `accountInfoProvider` достаточно
многословно. Несложно представить, как приведенный код мог бы еще больше усложниться, если бы интерфейс
Assembly имел асинхронную природу.

Таким образом, Assembly обязуется создать и вернуть любой сервис синхронно и только в главном потоке.
Создание объектов выглядит примерно следующим образом:

```objective-c
@protocol SODAccountAssembly <POSSchedulable>
// ...
@property (nonatomic, readonly) id<SODAccountInfoProvider> accountInfoProvider;
@property (nonatomic, readonly) id<SODNodeRepository> nodeRepository;
// ...
@end

@interface SODDropboxAccountAssembly : POSSchedulableObject <SODAccountAssembly>
// ...
@end

@implementation SODDropboxAccountAssembly
// ...
- (id<PFYAccountInfoProvider>)accountInfoProvider {
    if (_accountInfoProvider) {
        return _accountInfoProvider;
    }
    self.accountInfoProvider = [[PFYDropboxAccountInfoProvider alloc]
                                initWithHost:self.dropboxHost
                                accountID:self.account.ID];
    return _accountInfoProvider;
}
// ...
@end
```

Все выглядит достаточно просто пока вдруг не потребуется создать граф объектов, которые, во-первых, живут
в разных потоках, а во-вторых, для своей инициализации требуют вызвать один или несколько своих методов.

![payload](https://raw.github.com/pavelosipov/POSSchedulableObject/master/.images/dependency_cycle.jpg)

Проблема в этом сценарии состоит в том, что для инициализации объекта A необходимо в красном потоке
инициализировать объект B. Для того, чтобы с точки зрения клиента Assembly это произошло синхронно, на время
создания красного объекта B синий поток должен быть заблокирован. Однако объекту B нужен объект C. Последний
может создаться только в синем потоке. По аналогии с предыдущим шагом, на время его создания красный поток
блокируется и ожидает завершения создания объекта C. Ожидание на этом этапе будет длиться вечно, поскольку
событие, отправленное в синий поток, никогда не будет обработано, поскольку он был заблокирован при создании
объекта A.

Выход из сложившейся ситуации заключается в том, чтобы блокировать поток с помощью специальной spin-блокировки.
Она должна останавливать исполнение текущего потока, но при этом осуществлять прокручивание его цикла обработки
сообщений. В рамках библиотеки POSSchedulableObject специально для этого случая предусмотрен метод `posrx_await`
в категории к `RACSignal`.

```objective-c
@implementation RACSignal (POSSchedulableObject)

- (id)posrx_await {
    __block id result = nil;
    __block BOOL done = NO;
    [[self take:1] subscribeNext:^(id value) {
        result = value;
        done = YES;
    } error:^(NSError *e) {
        done = YES;
    }];
    if (result) {
        return result;
    }
    NSRunLoop *runLoop = NSRunLoop.currentRunLoop;
    while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.date] && !done) {}
    return result;
}

@end
```

В демо-приложении он используется для создания объекта `tracker`:

```objective-c
- (id<PFYTracker>)tracker {
    if (_tracker) {
        return _tracker;
    }
    PFYAppTracker *tracker = [[PFYAppTracker alloc]
                              initWithScheduler:self.backgroundScheduler
                              store:self.secureStore
                              environment:self.environment];
    self.tracker = [[[tracker schedule] map:^id(PFYAppTracker *scheduledTracker) {
        [scheduledTracker addService:
         [[PFYConsoleTracker alloc] initWithScheduler:scheduledTracker.scheduler]];
        return scheduledTracker;
    }] posrx_await];
    return _tracker;
}
```

##Ссылки
* [Видео доклада на CocoaHeads Moscow 2016](https://www.youtube.com/watch?v=XH667U8uzuE)
* [Презентация доклада про паттерн SchedulableObject](http://bit.ly/schedulable_object_pptx)

