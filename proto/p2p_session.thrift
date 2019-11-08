/**
 * Сессии
 */

namespace java   com.rbkmoney.fistful.p2p_session
namespace erlang p2p_session

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "destination.thrift"
include "identity.thrift"
include "msgpack.thrift"
include "user_interaction.thrift"

typedef fistful.P2PTransferID P2PTransferID
typedef base.ID               SessionID
typedef base.ID               ProviderID
// typedef string                AdapterState
typedef base.Resource         Resource
typedef base.ID               UserInterationID

/// Domain

struct Session {
    1: required SessionID      id
    2: required SessionStatus  status
    3: required P2PTransfer    p2p_transfer
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

struct P2PTransfer {
    1: required P2PTransferID           id
    2: required Resource                sender
    3: required Resource                receiver
    4: required base.Cash               cash
    5: optional identity.Identity       owner
}

// struct SessionCallback {
//     1: required base.Tag tag
// }

// struct UserInteraction {
//     1: required UserInterationID id
//     2: required user_interaction.UserInteraction user_interaction
// }

/// Session events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Session                      created
    // 2: SessionAdapterState          adapter_state
    // 3: SessionTransactionBound      transaction_bound
    // 4: SessionResult                finished
    // 5: SessionCallbackChange        callback
    // 6: SessionInteractionChange     user_interaction
}

// struct SessionAdapterState {
//     1: required AdapterState state
// }

// struct SessionTransactionBound {
//     1: required base.TransactionInfo trx_info
// }

// union SessionResult {
//     1: SessionResultSuccess  success
//     2: SessionResultFailed   failed
// }

// struct SessionResultSuccess {}

// struct SessionResultFailed {
//     1: required base.Failure failure
}

// union SessionCallbackChange {
//     1: SessionCallback         created
//     2: SessionCallbackStatus   status_changed
//     3: SessionCallbackResult   finished
// }

// union SessionCallbackStatus {
//     1: SessionCallbackStatusPending pending
//     2: SessionCallbackStatusSucceeded succeeded
// }

// struct SessionCallbackStatusPending {}
// struct SessionCallbackStatusSucceeded {}

// struct SessionCallbackResult {
//     1: required string payload
// }

// union SessionInteractionChange {
//     1: UserInteraction         created
//     2: UserInteractionStatus   status_changed
// }

// union UserInteractionStatus {
//     1: UserInteractionStatusPending pending
//     2: UserInteractionStatusFinished finished
// }

// struct UserInteractionStatusPending {}
// struct UserInteractionStatusFinished {}

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
