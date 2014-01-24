tasks
=====

Application
Primary Object used to start an application.  Really any application should start by requiring this module at their beginning.

Scheduler
The scheduler at the core of the Application object.  The scheduler supports the coroutine multi-tasking environment.

waitForCondition
implemenation of task suspension based on a predicate.

waitForIO
Implementation of task suspension based on blocking IO

waitForSignal
Implementation of task suspension based on blocking for an 'event'

waitForTime
Implementation of task suspension based on waiting for a timer to expire


TINNThread
Implements a OS system level thread, which has its own LuaState object embedded.

LuaState
Encapsulation of the LuaState object.

Task
Core unit of task representation for the scheduler.

Timer
A timer object returned from time related api calls.  Provides a "cancel"  function so the timer can be cancelled.