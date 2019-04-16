/**
 * Трансферы
 */

namespace java   com.rbkmoney.fistful.transfer
namespace erlang transfer

include "base.thrift"
include "fistful.thrift"
include "identity.thrift"
include "cashflow.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "msgpack.thrift"

typedef fistful.WithdrawalID  WithdrawalID

typedef base.ID               SessionID
typedef base.ID               ProviderID
typedef base.ID               TransferID
typedef fistful.WalletID      WalletID
typedef fistful.SourceID      SourceID
typedef fistful.DestinationID DestinationID
typedef fistful.AccountID     AccountID
typedef base.ExternalID       ExternalID

/// Domain

union TransferType {
    1: TransferDeposit     deposit
    2: TransferWithdrawal  withdrawal
}

struct TransferDeposit {}
struct TransferWithdrawal {}

struct Transfer {
    1: required TransferType   transfer_type
    2: required TransferID     id
    3: required base.Cash      body
    4: optional ExternalID     external_id

    5: required TransferParams params
}

union TransferParams {
    1: DepositParams      deposit
    2: WithdrawalParams   withdrawal
}

struct DepositParams {
    1: required WalletID       wallet_id
    2: required SourceID       source_id
}

struct WithdrawalParams {
    1: required WalletID       wallet_id
    2: required DestinationID  destination_id
}

union TransferStatus {
    1: TransferPending      pending
    2: TransferSucceeded    succeeded
    3: TransferFailed       failed
}

struct TransferPending {}
struct TransferSucceeded {}
struct TransferFailed {
    1: required Failure failure
}

struct Failure {
    // TODO
}

struct Transaction {
    2: required TransferID              id
    3: required base.Cash               body
    4: required SessionData             session_data
    5: required cashflow.FinalCashFlow  final_cash_flow
}

union SessionData {
    1: SessionDataEmpty      empty
    2: SessionDataWithdrawal withdrawal
}

struct SessionDataEmpty {}
struct SessionDataWithdrawal {
    1: required SessionWithdrawalData     data
    2: required SessionWithdrawalParams   params
}

struct SessionWithdrawalData {
    1: required SessionID           id
    2: required base.Cash           cash
    3: required identity.IdentityID sender
    4: required identity.IdentityID receiver
}

struct SessionWithdrawalParams {
    1: required DestinationID   destination_id
    2: required ProviderID      provider_id
}

union TransactionStatus {
    1: TransactionPending      pending
    2: TransactionSucceeded    succeeded
    3: TransactionFailed       failed
}

struct TransactionPending {}
struct TransactionSucceeded {}
struct TransactionFailed {
    1: required Failure failure
}

struct PostingTransfer {
    1: required cashflow.FinalCashFlow cashflow
}

union PostingTransferStatus {
    1: PostingTransferCreated   created
    2: PostingTransferPrepared  prepared
    3: PostingTransferCommitted committed
    4: PostingTransferCancelled cancelled
}

struct PostingTransferCreated {}
struct PostingTransferPrepared {}
struct PostingTransferCommitted {}
struct PostingTransferCancelled {}

/// Transfer events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: TransferChange       transfer_changed
    2: TransferStatus       status_changed
    3: RouteChange          route_changed
    4: TransactionChange    transaction_changed
    5: ChildTransferChange  child_transfer_changed
}

union TransferChange {
    1: TransferOnCreate     created
}

struct TransferOnCreate {
    1: required Transfer    transfer
}

union RouteChange {
    1: RouteOnCreate        created
}

struct RouteOnCreate {
    1: required ProviderID  id
}

union TransactionChange {
    1: TransactionOnCreate      transaction_changed
    2: TransactionStatus        status_changed
    3: PostingTransferChange    posting_transfer_changed
    4: SessionChange            session_changed
}

struct TransactionOnCreate {
    1: required Transaction     transaction
}

union PostingTransferChange {
    1: PostingTransferOnCreate  created
    2: PostingTransferStatus    status_changed
}

struct PostingTransferOnCreate {
    1: required PostingTransfer posting_transfer
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
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required TransferID           source
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
}

struct AddEventsRepair {
    1: required list<Change>            events
    2: optional repairer.ComplexAction  action
}

exception TransferNotFound              {}

service Repairer {
    void Repair(1: TransferID id, 2: RepairScenario scenario)
        throws (
            1: TransferNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
