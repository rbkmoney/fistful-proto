/**
 * Сессии
 */

namespace java   com.rbkmoney.fistful.withdrawal_session
namespace erlang wthd_session

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "destination.thrift"
include "identity.thrift"
include "msgpack.thrift"

typedef fistful.WithdrawalID  WithdrawalID
typedef base.ID               SessionID
typedef base.ID               ProviderID
typedef msgpack.Value         AdapterState
/// Domain

struct Session {
    1: required SessionID      id
    2: required SessionStatus  status
    3: required Withdrawal     withdrawal
    4: required ProviderID     provider
}

union SessionStatus {
    1: SessionActive    active
    2: SessionFinished  finished
}

struct SessionActive {}
struct SessionFinished {
    1: SessionFinishedStatus status
}

union SessionFinishedStatus {
    1: SessionFinishedSuccess success
    2: SessionFinishedFailed  failed
}

struct SessionFinishedSuccess {}
struct SessionFinishedFailed {
    1: optional base.Failure failure
}

struct Withdrawal {
    1: required WithdrawalID            id
    2: required destination.Destination destination
    3: required base.Cash               cash
    4: optional identity.Identity       sender
    5: optional identity.Identity       receiver
}

/// Session events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Session       created
    2: AdapterState  next_state
    3: SessionResult finished
}

union SessionResult {
    1: SessionResultSuccess  success
    2: SessionResultFailed   failed
}

struct SessionResultSuccess {
    1: required base.TransactionInfo trx_info
}

struct SessionResultFailed {
    1: required base.Failure failure
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required SessionID            source
    4: required Event                payload
}

service EventSink {

    list<SinkEvent> GetEvents (1: eventsink.EventRange range)
        throws ()

    eventsink.EventID GetLastEventID ()
        throws (1: eventsink.NoLastEvent ex1)

}

/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
    2: SetResultRepair set_session_result
}

struct AddEventsRepair {
    1: required list<Event>             events
    2: optional repairer.ComplexAction  action
}

struct SetResultRepair {
    1: required SessionResult           result
}

service Repairer {
    void Repair(1: SessionID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WithdrawalSessionNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
