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
include "context.thrift"

/// Domain

typedef fistful.DestinationID     DestinationID
typedef account.Account           Account
typedef identity.IdentityID       IdentityID
typedef base.ExternalID           ExternalID
typedef base.CurrencySymbolicCode CurrencySymbolicCode

struct Destination {
    1: required string     name
    2: required Resource   resource
    3: optional ExternalID external_id
}

struct DestinationState {

}

struct DestinationParams {
    1: required DestinationID         id
    2: required IdentityID            identity_id
    3: required string                name
    4: required CurrencySymbolicCode  currency
    5: required DestinationResource   resource

    98: optional ExternalID           external_id
    99: optional context.ContextSet   context
}

struct DestinationResource {
    1: required string type
    2: required string token
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


service Management {
    DestinationState Create( 1: DestinationParams params)
        throws()
}

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
