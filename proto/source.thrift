/**
 * Место ввода денег в систему
 */

namespace java   com.rbkmoney.fistful.source
namespace erlang src

include "base.thrift"
include "fistful.thrift"
include "account.thrift"
include "identity.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"

/// Domain

typedef fistful.SourceID SourceID
typedef account.Account Account
typedef base.ExternalID ExternalID
typedef base.Timestamp Timestamp
typedef fistful.Blocking Blocking
typedef fistful.SourceName SourceName
typedef identity.IdentityID IdentityID
typedef base.CurrencyRef CurrencyRef
typedef base.EventID EventID
typedef base.EventRange EventRange

struct Source {
    4: optional SourceID id
    1: required string name
    2: required Resource resource
    3: optional ExternalID external_id
    /** TODO Выпилить статус после ухода от интерфейса админки */
    5: optional Status status
    6: optional Timestamp created_at
    7: optional context.ContextSet metadata
}

struct SourceState {
    4: optional SourceID id
    1: required string   name
    2: required Resource resource
    3: optional ExternalID external_id
    5: optional Status status
    6: optional Timestamp created_at
    7: optional context.ContextSet metadata
    8: optional Account account
    9: optional Blocking blocking

    /** Контекст сущности заданный при её старте */
    10: optional context.ContextSet context
}

struct SourceParams {
    5: required SourceID id
    1: required SourceName name
    2: required IdentityID identity_id
    3: required CurrencyRef currency
    4: required Resource resource
    6: optional context.ContextSet metadata
}

union Resource {
    1: Internal         internal
}

struct Internal {
    1: optional string  details
}

union Status {
    1: Authorized       authorized
    2: Unauthorized     unauthorized
}

struct Authorized {}
struct Unauthorized {}

service Management {

    SourceState Create (1: SourceParams params)
        throws (
            1: fistful.IDExists ex1
            2: fistful.IdentityNotFound ex2
            3: fistful.CurrencyNotFound ex3
            4: fistful.PartyInaccessible ex4
        )

    SourceState Get (1: SourceID id)
        throws (
            1: fistful.SourceNotFound ex1
        )
    
    context.ContextSet GetContext(1: SourceID id)
        throws (
            1: fistful.SourceNotFound ex1
        )
    
    list<Event> GetEvents(
        1: SourceID id
        2: EventRange range
    )
        throws (
            1: fistful.SourceNotFound ex1
        )
}

/// Source events

struct Event {
    1: required EventID              event_id
    2: required base.Timestamp       occured_at
    3: required Change               change
}

union Change {
    1: Source           created
    2: AccountChange    account
    3: StatusChange     status
}

union AccountChange {
    1: Account          created
}

struct StatusChange {
    1: required Status status
}

/// Event sink

struct EventSinkPayload {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required SourceID             source
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
    1: required list<Event>             events
    2: optional repairer.ComplexAction  action
}

service Repairer {
    void Repair(1: SourceID id, 2: RepairScenario scenario)
        throws (
            1: fistful.SourceNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
