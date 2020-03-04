/**
 * Переводы с кошелька на кошелек
 */

namespace java   com.rbkmoney.fistful.w2w_transfer
namespace erlang w2w_transfer

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "transfer.thrift"
include "w2w_adjustment.thrift"
include "w2w_status.thrift"
include "limit_check.thrift"
include "repairer.thrift"
include "context.thrift"
include "cashflow.thrift"

typedef base.EventID EventID
typedef fistful.W2WTransferID W2WTransferID
typedef fistful.AdjustmentID AdjustmentID
typedef fistful.WalletID WalletToID
typedef fistful.WalletID WalletFromID
typedef base.ExternalID ExternalID
typedef w2w_status.Status Status
typedef base.EventRange EventRange

struct W2WTransfer {
    1: required W2WTransferID id
    2: required WalletFromID wallet_from_id
    3: required WalletToID wallet_to_id
    4: required base.Cash body
    5: required base.Timestamp created_at
    6: required base.DataRevision domain_revision
    7: required base.PartyRevision party_revision
    8: optional Status status
    9: optional ExternalID external_id
}

struct W2WTransferState {
    1: required W2WTransferID id
    2: required WalletFromID wallet_from_id
    3: required WalletToID wallet_to_id
    4: required base.Cash body
    5: required base.Timestamp created_at
    6: required base.DataRevision domain_revision
    7: required base.PartyRevision party_revision
    8: optional Status status
    9: optional ExternalID external_id

    /** Контекст операции заданный при её старте */
    10: required context.ContextSet context

    /**
      * Набор проводок, который отражает предполагаемое движение денег между счетами.
      * Может меняться в процессе прохождения операции или после применения корректировок.
      */
    11: required cashflow.FinalCashFlow effective_final_cash_flow

    /** Перечень корректировок */
    12: required list<w2w_adjustment.AdjustmentState> adjustments
}

struct W2WTransferParams {
    1: required W2WTransferID id
    2: required WalletFromID wallet_from_id
    3: required WalletToID wallet_to_id
    4: required base.Cash body
    5: optional ExternalID external_id
}

struct Event {
    1: required EventID event_id
    2: required base.Timestamp occured_at
    3: required Change change
} 

union Change {
    1: CreatedChange created
    2: StatusChange status_changed
    3: TransferChange transfer
    4: AdjustmentChange adjustment
    5: LimitCheckChange limit_check
}

struct CreatedChange {
    1: required W2WTransfer w2w_transfer
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct AdjustmentChange {
    1: required AdjustmentID id
    2: required w2w_adjustment.Change payload
}

struct LimitCheckChange {
    1: required limit_check.Details details
}

exception InconsistentW2WTransferCurrency {
    1: required base.CurrencyRef w2w_transfer_currency
    2: required base.CurrencyRef wallet_from_currency
    3: required base.CurrencyRef wallet_to_currency
}

exception InvalidW2WTransferStatus {
    1: required Status w2w_transfer_status
}

exception ForbiddenStatusChange {
    1: required Status target_status
}

exception AlreadyHasStatus {
    1: required Status w2w_transfer_status
}

exception AnotherAdjustmentInProgress {
    1: required AdjustmentID another_adjustment_id
}


service Management {

    W2WTransferState Create(
        1: W2WTransferParams params
        2: context.ContextSet context
    )
        throws (
            1: fistful.WalletNotFound ex1
            2: fistful.InvalidOperationAmount ex2
            3: fistful.ForbiddenOperationCurrency ex3
            4: InconsistentW2WTransferCurrency ex4
        )

    W2WTransferState Get(
        1: W2WTransferID id
        2: EventRange range
    )
        throws (
            1: fistful.W2WNotFound ex1
        )

    context.ContextSet GetContext(1: W2WTransferID id)
        throws (
            1: fistful.W2WNotFound ex1
        )

    w2w_adjustment.AdjustmentState CreateAdjustment(
        1: W2WTransferID id
        2: w2w_adjustment.AdjustmentParams params
    )
        throws (
            1: fistful.W2WNotFound ex1
            2: InvalidW2WTransferStatus ex2
            3: ForbiddenStatusChange ex3
            4: AlreadyHasStatus ex4
            5: AnotherAdjustmentInProgress ex5
        )
}

/// Event sink

struct EventSinkPayload {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

struct SinkEvent {
    1: required eventsink.EventID id
    2: required base.Timestamp created_at
    3: required W2WTransferID source
    4: required EventSinkPayload payload
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
    1: required list<Change> events
    2: optional repairer.ComplexAction action
}

service Repairer {
    void Repair(1: W2WTransferID id, 2: RepairScenario scenario)
        throws (
            1: fistful.W2WNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
