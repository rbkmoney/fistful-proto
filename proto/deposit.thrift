/**
 * Вводы
 */

namespace java   com.rbkmoney.fistful.deposit
namespace erlang deposit

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "transfer.thrift"
include "deposit_revert.thrift"
include "deposit_revert_status.thrift"
include "deposit_revert_adjustment.thrift"
include "deposit_adjustment.thrift"
include "deposit_status.thrift"
include "limit_check.thrift"
include "repairer.thrift"
include "context.thrift"
include "cashflow.thrift"

typedef base.EventID            EventID
typedef fistful.DepositID       DepositID
typedef fistful.AdjustmentID    AdjustmentID
typedef fistful.DepositRevertID RevertID
typedef fistful.WalletID        WalletID
typedef fistful.SourceID        SourceID
typedef base.ExternalID         ExternalID
typedef deposit_status.Status   Status
typedef base.EventRange         EventRange

struct Deposit {
    5: required DepositID id
    1: required WalletID wallet_id
    2: required SourceID source_id
    3: required base.Cash body
    /** TODO Выпилить статус после ухода от интерфейса админки */
    6: optional Status status
    4: optional ExternalID external_id
    7: optional base.Timestamp created_at
    8: optional base.DataRevision domain_revision
    9: optional base.PartyRevision party_revision
    10: optional context.ContextSet metadata
}

struct DepositState {
    1: required DepositID id
    2: required WalletID wallet_id
    3: required SourceID source_id
    4: required base.Cash body
    5: optional Status status
    6: optional ExternalID external_id
    7: optional base.Timestamp created_at
    8: optional base.DataRevision domain_revision
    9: optional base.PartyRevision party_revision
    10: optional context.ContextSet metadata

    /** Контекст операции заданный при её старте */
    11: required context.ContextSet context

    /**
      * Набор проводок, который отражает предполагаемое движение денег между счетами.
      * Может меняться в процессе прохождения операции или после применения корректировок.
      */
    12: required cashflow.FinalCashFlow effective_final_cash_flow

    /** Перечень возвратов пополнения */
    13: required list<deposit_revert.RevertState> reverts

    /** Перечень корректировок */
    14: required list<deposit_adjustment.AdjustmentState> adjustments
}

struct DepositParams {
    1: required DepositID id
    2: required WalletID wallet_id
    3: required SourceID source_id
    4: required base.Cash body
    5: optional ExternalID external_id
    6: optional context.ContextSet metadata
}

struct Event {
    1: required EventID        event_id
    2: required base.Timestamp occured_at
    3: required Change         change
}

struct TimestampedChange {
    1: required base.Timestamp occured_at
    2: required Change         change
}

union Change {
    1: CreatedChange    created
    2: StatusChange     status_changed
    3: TransferChange   transfer
    4: RevertChange     revert
    5: AdjustmentChange adjustment
    6: LimitCheckChange limit_check
}

struct CreatedChange {
    1: required Deposit deposit
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct RevertChange {
    1: required RevertID id
    2: required deposit_revert.Change payload
}

struct AdjustmentChange {
    1: required AdjustmentID id
    2: required deposit_adjustment.Change payload
}

struct LimitCheckChange {
    1: required limit_check.Details details
}

exception InconsistentDepositCurrency {
    1: required base.CurrencyRef deposit_currency
    2: required base.CurrencyRef source_currency
    3: required base.CurrencyRef wallet_currency
}

exception InvalidDepositStatus {
    1: required Status deposit_status
}

exception ForbiddenStatusChange {
    1: required Status target_status
}

exception AlreadyHasStatus {
    1: required Status deposit_status
}

exception AnotherAdjustmentInProgress {
    1: required AdjustmentID another_adjustment_id
}

exception InconsistentRevertCurrency {
    1: required base.CurrencyRef revert_currency
    2: required base.CurrencyRef deposit_currency
}

exception InsufficientDepositAmount {
    1: required base.Cash revert_body
    2: required base.Cash deposit_amount
}

exception InvalidRevertStatus {
    1: required deposit_revert_status.Status revert_status
}

exception ForbiddenRevertStatusChange {
    1: required deposit_revert_status.Status target_status
}

exception RevertAlreadyHasStatus {
    1: required deposit_revert_status.Status revert_status
}

exception RevertNotFound {
    1: required RevertID id
}

service Management {

    DepositState Create(
        1: DepositParams params
        2: context.ContextSet context
    )
        throws (
            1: fistful.WalletNotFound ex1
            2: fistful.SourceNotFound ex2
            3: fistful.SourceUnauthorized ex3
            4: fistful.InvalidOperationAmount ex4
            5: fistful.ForbiddenOperationCurrency ex5
            6: InconsistentDepositCurrency ex6
        )

    DepositState Get(
        1: DepositID id
        2: EventRange range
    )
        throws (
            1: fistful.DepositNotFound ex1
        )

    context.ContextSet GetContext(1: DepositID id)
        throws (
            1: fistful.DepositNotFound ex1
        )

    list<Event> GetEvents(
        1: DepositID id
        2: EventRange range
    )
        throws (
            1: fistful.DepositNotFound ex1
        )

    deposit_adjustment.AdjustmentState CreateAdjustment(
        1: DepositID id
        2: deposit_adjustment.AdjustmentParams params
    )
        throws (
            1: fistful.DepositNotFound ex1
            2: InvalidDepositStatus ex2
            3: ForbiddenStatusChange ex3
            4: AlreadyHasStatus ex4
            5: AnotherAdjustmentInProgress ex5
        )

    deposit_revert.RevertState CreateRevert(
        1: DepositID id
        2: deposit_revert.RevertParams params
    )
        throws (
            1: fistful.DepositNotFound ex1
            2: InvalidDepositStatus ex2
            3: InconsistentRevertCurrency ex3
            4: InsufficientDepositAmount ex4
            5: fistful.InvalidOperationAmount ex5
        )

    deposit_revert_adjustment.AdjustmentState CreateRevertAdjustment(
        1: DepositID id
        2: RevertID revert_id
        3: deposit_revert_adjustment.AdjustmentParams params
    )
        throws (
            1: fistful.DepositNotFound ex1
            2: RevertNotFound ex2
            3: InvalidRevertStatus ex3
            4: ForbiddenRevertStatusChange ex4
            5: RevertAlreadyHasStatus ex5
            6: AnotherAdjustmentInProgress ex6
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
    3: required DepositID            source
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
    1: required list<Change>            events
    2: optional repairer.ComplexAction  action
}

service Repairer {
    void Repair(1: DepositID id, 2: RepairScenario scenario)
        throws (
            1: fistful.DepositNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
