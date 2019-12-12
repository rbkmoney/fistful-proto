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
include "msgpack.thrift"
include "user_interaction.thrift"

typedef fistful.P2PTransferID P2PTransferID
typedef base.ID               SessionID
typedef base.ID               ProviderID
typedef binary                AdapterState
typedef base.Resource         Resource
typedef base.ID               UserInteractionID

/// Domain

struct Session {
    1: required SessionID           id
    2: required SessionStatus       status
    3: required P2PTransfer         p2p_transfer
    4: required ProviderID          provider
    5: required base.DataRevision   domain_revision
    6: required base.PartyRevision  party_revision
}

union SessionStatus {
    1: SessionActive    active
    2: SessionFinished  finished
}

struct SessionActive {}
struct SessionFinished {
    1: Result result
}

struct P2PTransfer {
    1: required P2PTransferID           id
    2: required Resource                sender
    3: required Resource                receiver
    4: required base.Cash               cash
    5: optional base.Timestamp          deadline
}

struct Callback {
    1: required base.Tag tag
}

struct UserInteraction {
    1: required UserInteractionID id
    2: required user_interaction.UserInteraction user_interaction
}

/// Session events

struct Event {
    1: required base.EventID         event
    2: required base.Timestamp       occured_at
    3: required Change               change
}

union Change {
    1: CreatedChange                created
    2: AdapterStateChange           adapter_state
    3: TransactionBoundChange       transaction_bound
    4: ResultChange                 finished
    5: CallbackChange               callback
    6: UserInteractionChange        ui
}

struct CreatedChange {
    1: required Session session
}

struct AdapterStateChange {
    1: required AdapterState state
}

struct TransactionBoundChange {
    1: required base.TransactionInfo trx_info
}

struct ResultChange {
    1: required Result result
}

union Result {
    1: ResultSuccess  success
    2: ResultFailed   failed
}

struct ResultSuccess {}

struct ResultFailed {
    1: required base.Failure failure
}

struct CallbackChange {
    1: required base.Tag tag
    2: required CallbackChangePayload payload
}

union CallbackChangePayload {
    1: CallbackCreatedChange  created
    2: CallbackStatusChange   status_changed
    3: CallbackResultChange   finished
}

struct CallbackCreatedChange {
    1: required Callback callback
}

struct CallbackStatusChange {
    1: required CallbackStatus status
}

union CallbackStatus {
    1: CallbackStatusPending pending
    2: CallbackStatusSucceeded succeeded
}

struct CallbackStatusPending {}
struct CallbackStatusSucceeded {}

struct CallbackResultChange {
    1: required binary payload
}

struct UserInteractionChange {
    1: required UserInteractionID id
    2: required UserInteractionChangePayload payload
}

union UserInteractionChangePayload {
    1: UserInteractionCreatedChange  created
    2: UserInteractionStatusChange   status_changed
}

struct UserInteractionCreatedChange {
    1: required UserInteraction ui
}

struct UserInteractionStatusChange {
    1: required UserInteractionStatus status
}

union UserInteractionStatus {
    1: UserInteractionStatusPending pending
    2: UserInteractionStatusFinished finished
}

struct UserInteractionStatusPending {}
struct UserInteractionStatusFinished {}

/// Event sink

struct EventSinkPayload {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp       occured_at
    3: required list<Change>         changes
}

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required SessionID            source
    4: required EventSinkPayload     payload
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
    1: required list<Change>            events
    2: optional repairer.ComplexAction  action
}

struct SetResultRepair {
    1: required ResultChange            result
}

service Repairer {
    void Repair(1: SessionID id, 2: RepairScenario scenario)
        throws (
            1: fistful.P2PSessionNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
