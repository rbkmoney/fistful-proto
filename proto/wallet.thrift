/**
 * Кошельки
 */

namespace java   com.rbkmoney.fistful.wallet
namespace erlang wlt

include "base.thrift"
include "fistful.thrift"
include "identity.thrift"
include "eventsink.thrift"

/// Domain

typedef fistful.WalletID WalletID

struct Wallet {
    1: optional string name
}

struct Account {
    1: required identity.IdentityID identity
    2: required base.CurrencyRef currency
}

/// Wallet events

struct Event {
    1: required base.EventID id
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Wallet           created
    2: AccountChange    account
}

union AccountChange {
    1: Account          created
}

/// Event sink

struct SinkEvent {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp       created_at
    3: required WalletID             source
    4: required Event                payload
}

service EventSink {

    list<SinkEvent> GetEvents (1: eventsink.EventRange range)
        throws ()

    eventsink.EventID GetLastEventID ()
        throws (1: eventsink.NoLastEvent ex1)

}
