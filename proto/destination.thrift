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
include "repairer.thrift"

/// Domain

typedef fistful.DestinationID     DestinationID
typedef account.Account           Account
typedef identity.IdentityID       IdentityID
typedef base.ExternalID           ExternalID
typedef base.CurrencySymbolicCode CurrencySymbolicCode
typedef base.Timestamp            Timestamp
typedef fistful.Blocking          Blocking

struct Destination {
    1: required string        name
    2: required Resource      resource
    3: optional ExternalID    external_id
    4: optional Account       account
    5: optional Status        status

    6: optional DestinationID        id
    7: optional Timestamp            created_at
    8: optional Blocking             blocking

    99: optional context.ContextSet  context
}

struct DestinationParams {
    1: DestinationID                  id
    2: required IdentityID            identity
    3: required string                name
    4: required CurrencySymbolicCode  currency
    5: required Resource              resource
    6: optional ExternalID            external_id

    99: optional context.ContextSet   context
}

union Resource {
    1: base.BankCard     bank_card
    2: base.CryptoWallet crypto_wallet
}

union Status {
    1: Authorized       authorized
    2: Unauthorized     unauthorized
}

struct Authorized {}
struct Unauthorized {}

service Management {

    Destination Create(
        1: DestinationParams params)
        throws(
            1: fistful.IDExists              ex1
            2: fistful.IdentityNotFound      ex2
            3: fistful.CurrencyNotFound      ex3
            4: fistful.PartyInaccessible     ex4
        )

    Destination Get(1: DestinationID id)
        throws(
            1: fistful.DestinationNotFound ex1
        )
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

/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
}

struct AddEventsRepair {
    1: required list<Event>             events
    2: optional repairer.ComplexAction  action
}

service Repairer {
    void Repair(1: DestinationID id, 2: RepairScenario scenario)
        throws (
            1: fistful.DestinationNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
