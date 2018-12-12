/**
 * Выводы
 */

namespace java   com.rbkmoney.fistful.withdrawal
namespace erlang wthd

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"
include "eventsink.thrift"

typedef fistful.WithdrawalID  WithdrawalID

typedef base.ID               SessionID
typedef base.ID               ProviderID
typedef fistful.WalletID      WalletID
typedef fistful.DestinationID DestinationID
typedef fistful.AccountID     AccountID
typedef base.ExternalID       ExternalID

/// Domain

struct Withdrawal {
    1: required WalletID       source
    2: required DestinationID  destination
    3: required base.Cash      body
    4: optional ExternalID     external_id
}

union WithdrawalStatus {
    1: WithdrawalPending pending
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed failed
}

struct WithdrawalPending {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {
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

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required WithdrawalID         source
    4: required Event                payload
}

service EventSink {

    list<SinkEvent> GetEvents (1: eventsink.EventRange range)
        throws ()

    eventsink.EventID GetLastEventID ()
        throws (1: eventsink.NoLastEvent ex1)

}
