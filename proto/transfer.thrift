/**
 * Трансферы
 */

namespace java   com.rbkmoney.fistful.transfer
namespace erlang transfer

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"
include "eventsink.thrift"
include "repairer.thrift"

include "t_withdrawal.thrift"
include "t_deposit.thrift"
include "transaction.thrift"

typedef base.ExternalID                 ExternalID
typedef base.Cash                       Cash
typedef base.Timestamp                  Timestamp
typedef fistful.TransferID              TransferID
typedef fistful.WalletID                WalletID
typedef fistful.MachineAlreadyWorking   MachineAlreadyWorking
typedef cashflow.FinalCashFlow          FinalCashFlow
typedef t_deposit.DepositParams         DepositParams
typedef t_withdrawal.WithdrawalParams   WithdrawalParams
typedef t_withdrawal.RouteWithdrawal    RouteWithdrawal
typedef transaction.TransactionChange   TransactionChange
typedef transaction.SessionData         SessionData
typedef eventsink.SequenceID            SequenceID
typedef eventsink.EventID               EventID
typedef eventsink.EventRange            EventRange
typedef eventsink.NoLastEvent           NoLastEvent
typedef repairer.ComplexAction          ComplexAction

/// Domain

struct Target {
    1: required base.ID                 root_id
    2: required TransferType            root_type
    3: required base.ID                 target_id
}

union TransferType {
    1: TransferDeposit     deposit
    2: TransferWithdrawal  withdrawal
    3: TransferRevert      revert
    4: TransferAdjustment  adjustment
}

struct TransferDeposit {}
struct TransferWithdrawal {}
struct TransferRevert {}
struct TransferAdjustment {}

struct Transfer {
    1: required TransferType   transfer_type
    2: required TransferID     id
    3: required Cash           body
    4: optional ExternalID     external_id

    5: required TransferParams params
}

union TransferParams {
    1: DepositParams       deposit
    2: WithdrawalParams    withdrawal
    3: RevertParams        revert
    4: AdjustmentParams    adjustment
}

struct RevertParams {
    1: required WalletID        wallet_id
    2: required SessionData     session_data
    3: required FinalCashFlow   revert_cash_flow
    4: required Target          target
    5: optional string          reason
}

struct AdjustmentParams {
    1: required TransferStatus     status
    2: optional FinalCashFlow      cashflow
}

union TransferStatus {
    1: TransferPending      pending
    2: TransferSucceeded    succeeded
    3: TransferFailed       failed
    4: TransferReverted     reverted
}

struct TransferPending {}
struct TransferSucceeded {}
struct TransferFailed {
    1: required Failure failure
}
struct TransferReverted {
    1: optional string reason
}

struct Failure {
    // TODO
}

/// Transfer events

struct Event {
    1: required SequenceID      sequence_id
    2: required Timestamp       occured_at
    3: required list<Change>    changes
}

union Change {
    1: TransferCreated      created
    2: TransferStatus       status_changed
    3: RouteChange          route_changed
    4: TransactionChange    transaction_changed
    5: ChildTransferChange  child_transfer_changed
}

struct TransferCreated {
    1: required Transfer    transfer
}

union RouteChange {
    1: RouteCreated         created
}

union RouteCreated {
    1: RouteWithdrawal      withdrawal
}

struct ChildTransferChange {
    1: required TransferType   type
    2: required TransferID     id
    3: required list<Change>   changes
    4: required TransferParent parent
}

struct TransferParent {
    1: required TransferType   type
    2: required TransferID     id
}

/// Event sink

struct SinkEvent {
    1: required EventID    id
    2: required Timestamp            created_at
    3: required TransferID           source_id
    4: required Event                payload
}

service EventSink {

    list<SinkEvent> GetEvents (1: EventRange range)
        throws ()

    EventID GetLastEventID ()
        throws (1: NoLastEvent ex1)

}

/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
}

struct AddEventsRepair {
    1: required list<Change>   events
    2: optional ComplexAction  action
}

exception TransferNotFound              {}

service Repairer {
    void Repair(1: TransferID id, 2: RepairScenario scenario)
        throws (
            1: TransferNotFound ex1
            2: MachineAlreadyWorking ex2
        )
}
