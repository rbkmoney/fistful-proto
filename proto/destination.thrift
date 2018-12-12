/**
 * Место ввода денег в систему
 */

namespace java   com.rbkmoney.fistful.destination
namespace erlang dst

include "base.thrift"
include "fistful.thrift"
include "account.thrift"
include "identity.thrift"
include "eventsink.thrift"

/// Domain

typedef fistful.DestinationID DestinationID
typedef account.Account Account
typedef base.ExternalID ExternalID

struct Destination {
    1: required string   name
    2: required Resource resource
    3: optional ExternalID external_id
}

union Resource {
    1: base.BankCard    bank_card
}

union Status {
    1: Authorized       authorized
    2: Unauthorized     unauthorized
}

struct Authorized {}
struct Unauthorized {}

/// Source events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Destination      created
    2: AccountChange    account
    3: StatusChange     status
}

union AccountChange {
    1: Account          created
}

union StatusChange {
    1: Status          changed
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required DestinationID        source
    4: required Event                payload
}

service EventSink {

    list<SinkEvent> GetEvents (1: eventsink.EventRange range)
        throws ()

    eventsink.EventID GetLastEventID ()
        throws (1: eventsink.NoLastEvent ex1)

}
