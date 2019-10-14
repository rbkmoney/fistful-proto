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
typedef msgpack.Value         AdapterState
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
    3: SessionSuspended suspended
    4: SessionActivated activated
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

/// Session events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Session                      created
    2: SessionAdapterStateChanged   adapter_state_changed
    3: SessionResult                finished
    4: SessionSuspended             suspended
    5: SessionActivated             activated
    6: SessionInteractionRequested  interaction_requested
}

struct SessionAdapterStateChanged {
    1: required AdapterState state
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

struct SessionSuspended {
    1: optional base.Tag tag
}

struct SessionActivated {}

struct SessionInteractionRequested {
    /** Необходимое взаимодействие */
    1: required UserInteraction interaction
}

struct UserInteraction {
    /**
     * Идентификатор запроса взаимодействия с пользователем.
     * Должен быть уникален в пределах операции.
     * Этот идентификатор будет виден внешним пользователям.
     */
    1: required UserInterationID id

    /** Что именно необходимо сделать с запросом взаимодействия */
    2: required UserInteractionIntent intent
}

union UserInteractionIntent {
    /**
     * Новый запрос взаимодействия с пользователем.
     * Для одного идентификатора может быть указан не более одного раза.
     */
    1: UserInteractionCreate create

    /**
     * Запрос взаимодействия с пользователем более не актуален.
     */
    2: UserInteractionFinish finish
}

struct UserInteractionCreate {
    1: required user_interaction.UserInteraction user_interaction
}

struct UserInteractionFinish {}

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
