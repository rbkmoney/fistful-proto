/**
 * Выводы
 */

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"

typedef base.ID               SessionID
typedef fistful.WalletID      WalletID
typedef fistful.DestinationID DestinationID
typedef fistful.WithdrawalID  WithdrawalID
typedef fistful.AccountID     AccountID

/// Domain

struct Withdrawal {
    1: optional WalletID       source
    2: optional DestinationID  destination
    3: required base.Cash      body
}

union WithdrawalStatus {
    1: WithdrawalPending pending
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed failed
}

struct WithdrawalPending {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {
    1: optional Failure failure
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
    1: required base.EventID id
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Withdrawal       created
    2: WithdrawalStatus status_changed
    3: TransferChange   transfer
    4: SessionChange    session
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

/// Event sink

typedef i64 SinkEventID

struct SinkEvent {
    1: required SinkEventID id
    2: required base.Timestamp created_at
    3: required fistful.WithdrawalID source
    4: required Event payload
}

struct SinkEventRange {
    1: optional SinkEventID after
    2: required i32 limit
}

exception NoLastEvent {}

service EventSink {

    list<SinkEvent> GetEvents (1: SinkEventRange range)
        throws ()

    SinkEventID GetLastEventID ()
        throws (1: NoLastEvent ex1)

}
