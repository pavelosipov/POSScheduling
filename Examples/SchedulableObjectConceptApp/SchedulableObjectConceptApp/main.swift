//
//  main.swift
//  SchedulableObjectConceptApp
//
//  Created by Pavel Osipov on 26.10.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

import Foundation
import Dispatch

typealias Event = () -> Void

class EventQueue {
    private let semaphore = DispatchSemaphore(value: 1)
    private var events = [Event]()
    
    func pushEvent(event: @escaping Event) {
        semaphore.wait()
        events.append(event)
        semaphore.signal()
    }
    
    func resetEvents() -> [Event] {
        semaphore.wait()
        let currentEvents = events
        events = [Event]()
        semaphore.signal()
        return currentEvents
    }
}

class RunLoop {
    let eventQueue = EventQueue()
    var disposed = false
    
    @objc func run() {
        while !disposed {
            for event in eventQueue.resetEvents() {
                event()
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
}

class Scheduler {
    private let runLoop = RunLoop()
    private let thread: Thread
    
    init() {
        self.thread = Thread(
            target: runLoop,
            selector: #selector(RunLoop.run),
            object: nil)
        thread.start()
    }
    
    func schedule(event: @escaping Event) {
        runLoop.eventQueue.pushEvent(event: event)
    }
    
    func dispose() {
        runLoop.disposed = true
    }
}

class SchedulableObject<T> {
    let object: T
    private let scheduler: Scheduler
    
    init(object: T, scheduler: Scheduler) {
        self.object = object
        self.scheduler = scheduler
    }
    
    func schedule(event: @escaping (T) -> Void) {
        scheduler.schedule {
            event(self.object)
        }
    }
}

class PrintOptionsProvider {
    var richFormatEnabled = false;
}

class Printer {
    private let optionsProvider: PrintOptionsProvider
    
    init(optionsProvider: PrintOptionsProvider) {
        self.optionsProvider = optionsProvider
    }
    
    func doWork(what: String) {
        if optionsProvider.richFormatEnabled {
            print("\(Thread.current): out \(what)")
        } else {
            print("out \(what)")
        }
    }
}

class Assembly {
    let backgroundScheduler = Scheduler()
    let printOptionsProvider: SchedulableObject<PrintOptionsProvider>
    let printer: SchedulableObject<Printer>
    
    init() {
        let optionsProvider = PrintOptionsProvider()
        self.printOptionsProvider = SchedulableObject<PrintOptionsProvider>(
            object: optionsProvider,
            scheduler: backgroundScheduler);
        self.printer = SchedulableObject<Printer>(
            object: Printer(optionsProvider: optionsProvider),
            scheduler: backgroundScheduler)
    }
}

let assembly = Assembly()

while true {
    guard let value = readLine(strippingNewline: true) else {
        continue
    }
    if (value == "q") {
        assembly.backgroundScheduler.dispose()
        break;
    }
    assembly.printOptionsProvider.schedule(
        event: { (printOptionsProvider: PrintOptionsProvider) in
            printOptionsProvider.richFormatEnabled = arc4random() % 2 == 0;
    })
    assembly.printer.schedule(event: { (printer: Printer) in
        printer.doWork(what: value)
    })
    
    // Simplified version
    //
    // assembly.backgroundScheduler.schedule {
    //     assembly.printOptionsProvider.object.richFormatEnabled = arc4random() % 2 == 0
    //     assembly.printer.object.doWork(what: value)
    // }
}



