/**
 * Выводы
 */

namespace java   com.rbkmoney.fistful.withdrawal
namespace erlang wthd

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"

typedef fistful.WithdrawalID  WithdrawalID

typedef base.ID               SessionID
typedef base.ID               ProviderID
typedef base.EventID          EventID
typedef fistful.WalletID      WalletID
typedef fistful.DestinationID DestinationID
typedef fistful.AccountID     AccountID
typedef base.ExternalID       ExternalID
typedef base.EventRange       EventRange
/// Domain

struct WithdrawalParams {
    1: required WithdrawalID  id
    2: required WalletID      source
    3: required DestinationID destination
    4: required base.Cash     body
    5: required ExternalID    external_id

    99: optional context.ContextSet   context
}

struct Withdrawal {
    1: required WalletID       source
    2: required DestinationID  destination
    3: required base.Cash      body
    4: optional ExternalID     external_id
    5: optional WithdrawalID        id
    6: optional WithdrawalStatus    status

    99: optional context.ContextSet context
}

union WithdrawalStatus {
    1: WithdrawalPending   pending
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed    failed
}

struct WithdrawalPending {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {
    1: required Failure failure
}

struct Event {
    1: required EventID              event
    2: required base.Timestamp       occured_at
    3: required Change               change
}

struct Transfer {
    1: required cashflow.FinalCashFlow cashflow
}

union TransferStatus {
    1: TransferCreated   created
    2: TransferPrepared  prepared
    3: TransferCommitted committed
    4: TransferCancelled cancelled
}

struct TransferCreated   {}
struct TransferPrepared  {}
struct TransferCommitted {}
struct TransferCancelled {}


struct Failure {
    // TODO
}

/// Withdrawal events


union Change {
    1: Withdrawal       created
    2: WithdrawalStatus status_changed
    3: TransferChange   transfer
    4: SessionChange    session
    5: RouteChange      route
}

union TransferChange {
    1: Transfer         created
    2: TransferStatus   status_changed
}

struct SessionChange {
    1: required SessionID id
    2: required SessionChangePayload payload
}

union SessionChangePayload {
    1: SessionStarted   started
    2: SessionFinished  finished
}

struct SessionStarted {}
struct SessionFinished {}

struct RouteChange {
    1: required ProviderID id
}

service Management {

    Withdrawal Create(1: WithdrawalParams params)
        throws (
            1: fistful.IDExists                    ex1
            2: fistful.WalletNotFound              ex2
            3: fistful.DestinationNotFound         ex3
            4: fistful.DestinationUnauthorized     ex4
            5: fistful.WithdrawalCurrencyInvalid   ex5
            6: fistful.WithdrawalCashAmountInvalid ex6
        )

    Withdrawal Get(1: WithdrawalID id)
        throws ( 1: fistful.WithdrawalNotFound ex1)

    list<Event> GetEvents(
        1: WithdrawalID id
        2: EventRange range)
        throws (
            1: fistful.WithdrawalNotFound ex1
        )
}

/// Event sink

struct EventSinkPayload {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp       occured_at
    3: required list<Change>         changes
}

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required WithdrawalID         source
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
}

struct AddEventsRepair {
    1: required list<Event>             events
    2: optional repairer.ComplexAction  action
}

service Repairer {
    void Repair(1: WithdrawalID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WithdrawalNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
