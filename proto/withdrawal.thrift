/**
 * Выводы
 */

namespace java   com.rbkmoney.fistful.withdrawal
namespace erlang wthd

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"
include "transfer.thrift"
include "withdrawal_adjustment.thrift"
include "withdrawal_status.thrift"
include "limit_check.thrift"

typedef base.ID                  SessionID
typedef base.ID                  ProviderID
typedef base.EventID             EventID
typedef fistful.WithdrawalID     WithdrawalID
typedef fistful.AdjustmentID     AdjustmentID
typedef fistful.WalletID         WalletID
typedef fistful.DestinationID    DestinationID
typedef base.ExternalID          ExternalID
typedef withdrawal_status.Status Status
typedef base.EventRange          EventRange
typedef base.Resource            Resource

/// Domain

struct WithdrawalParams {
    1: required WalletID      source
    2: required DestinationID destination
    3: required base.Cash     body
    4: required ExternalID    external_id

    99: optional context.ContextSet   context
}

struct Withdrawal {
    1: required WalletID       source
    2: required DestinationID  destination
    3: required base.Cash      body
    4: optional ExternalID     external_id
    5: optional WithdrawalID   id
    6: optional Status         status

    99: optional context.ContextSet context
}

struct Event {
    1: required EventID              event
    2: required base.Timestamp       occured_at
    3: required Change               change
}

union Change {
    1: CreatedChange       created
    2: StatusChange        status_changed
    6: ResourceChange      resource
    5: RouteChange         route
    3: TransferChange      transfer
    8: LimitCheckChange    limit_check
    4: SessionChange       session
    7: AdjustmentChange    adjustment
}

struct CreatedChange {
    1: required Withdrawal withdrawal
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct AdjustmentChange {
    1: required AdjustmentID id
    2: required withdrawal_adjustment.Change payload
}

struct LimitCheckChange {
    1: required limit_check.Details details
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

struct SessionFinished {
    1: required SessionResult result
}

union SessionResult {
    1: SessionSucceeded succeeded
    2: SessionFailed    failed
}

struct SessionSucceeded {
    1: required base.TransactionInfo trx_info
}

struct SessionFailed {
    1: required base.Failure failure
}

struct RouteChange {
    1: required Route route
}

struct Route {
    1: required ProviderID provider_id
}

union ResourceChange {
    1: ResourceGot got
}

struct ResourceGot {
    1: required Resource resource
}

service Management {
    Withdrawal Create(
        1: WithdrawalID id
        2: WithdrawalParams params)
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
    1: required list<Change>             events
    2: optional repairer.ComplexAction  action
}

service Repairer {
    void Repair(1: WithdrawalID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WithdrawalNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
