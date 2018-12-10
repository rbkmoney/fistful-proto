/**
 * Вводы
 */

namespace java   com.rbkmoney.fistful.deposit
namespace erlang deposit

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"
include "eventsink.thrift"

typedef fistful.WithdrawalID  WithdrawalID

typedef base.ID               SessionID
typedef base.ID               ProviderID
typedef fistful.DepositID     DepositID
typedef fistful.WalletID      WalletID
typedef fistful.SourceID      SourceID
typedef fistful.AccountID     AccountID
typedef base.ID               ExternalID

/// Domain

struct Deposit {
    1: required WalletID       wallet
    2: required SourceID       source
    3: required base.Cash      body
}

union DepositStatus {
    1: DepositPending pending
    2: DepositSucceeded succeeded
    3: DepositFailed failed
}

struct DepositPending {}
struct DepositSucceeded {}
struct DepositFailed {
    1: required Failure failure
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

struct TransferCreated {}
struct TransferPrepared {}
struct TransferCommitted {}
struct TransferCancelled {}

struct Failure {
    // TODO
}

/// Withdrawal events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Deposit          created
    2: DepositStatus    status_changed
    3: TransferChange   transfer
    4: ExternalID       external_changed
}

union TransferChange {
    1: Transfer         created
    2: TransferStatus   status_changed
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required DepositID            source
    4: required Event                payload
}

service EventSink {

    list<SinkEvent> GetEvents (1: eventsink.EventRange range)
        throws ()

    eventsink.EventID GetLastEventID ()
        throws (1: eventsink.NoLastEvent ex1)

}
