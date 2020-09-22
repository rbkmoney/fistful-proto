/**
 * Шаблоны переводов
 */

namespace java   com.rbkmoney.fistful.p2p.template
namespace erlang p2p_template

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"
include "p2p_transfer.thrift"

/// Domain

typedef fistful.P2PTemplateID P2PTemplateID
typedef fistful.IdentityID IdentityID
typedef base.EventID EventID
typedef base.ExternalID ExternalID
typedef base.Timestamp Timestamp
typedef fistful.Blocking Blocking
typedef base.EventRange EventRange

struct P2PTemplateParams {
    1: required P2PTemplateID id
    2: required IdentityID identity_id
    3: required P2PTemplateDetails template_details
    4: optional ExternalID external_id
}

struct P2PTemplateState {
    1: required P2PTemplateID id
    2: required IdentityID identity_id
    3: required Timestamp created_at
    4: required base.DataRevision domain_revision
    5: required base.PartyRevision party_revision
    6: required P2PTemplateDetails template_details
    7: optional Blocking blocking
    8: optional ExternalID external_id
    9: optional context.ContextSet context
}

struct P2PTemplate {
    1: required P2PTemplateID id
    2: required IdentityID identity_id
    3: required Timestamp created_at
    4: required base.DataRevision domain_revision
    5: required base.PartyRevision party_revision
    6: required P2PTemplateDetails template_details
    7: optional ExternalID external_id
}

struct P2PTemplateDetails {
    1: required P2PTemplateBody body
    2: optional P2PTemplateMetadata metadata
}

struct P2PTemplateBody {
    1: required Cash value
}

struct Cash {
    1: optional base.Amount amount
    2: required base.CurrencyRef currency
}

struct P2PTemplateMetadata {
    1: required context.ContextSet value
}

/// P2PTemplate Quote

struct P2PTemplateQuoteParams {
    1: required base.Resource sender
    2: required base.Resource receiver
    3: required base.Cash body
}

/// P2PTemplate Transfer

struct P2PTemplateTransferParams {
    1: required p2p_transfer.P2PTransferID id
    2: required p2p_transfer.Sender sender
    3: required p2p_transfer.Receiver receiver
    4: required base.Cash body
    5: optional p2p_transfer.Quote quote
    6: optional base.Timestamp deadline
    7: optional base.ClientInfo client_info
    8: optional context.ContextSet metadata
}

/// P2PTemplate events

struct Event {
    1: required EventID              event_id
    2: required base.Timestamp       occured_at
    3: required Change               change
}

struct TimestampedChange {
    1: required base.Timestamp       occured_at
    2: required Change               change
}

union Change {
    1: CreatedChange created
    2: BlockingChange blocking_changed
}

struct CreatedChange {
    1: required P2PTemplate p2p_template
}

struct BlockingChange {
    1: required Blocking blocking
}

///

service Management {

    P2PTemplateState Create (
        1: P2PTemplateParams params
        2: context.ContextSet context
    )
        throws (
            1: fistful.IdentityNotFound ex1
            2: fistful.CurrencyNotFound ex2
            3: fistful.PartyInaccessible ex3
            5: fistful.InvalidOperationAmount ex5
        )

    P2PTemplateState Get (
        1: P2PTemplateID id
        2: EventRange range
    )
        throws (1: fistful.P2PTemplateNotFound ex1)

    context.ContextSet GetContext(
        1: P2PTemplateID id
    )
        throws (
            1: fistful.P2PTemplateNotFound ex1
        )

    void SetBlocking (
        1: P2PTemplateID id,
        2: Blocking value
    )
        throws (
            1: fistful.P2PTemplateNotFound ex1
        )

    p2p_transfer.Quote GetQuote(
        1: P2PTemplateID id
        2: P2PTemplateQuoteParams params
    )
        throws (
            1: fistful.P2PTemplateNotFound ex1
            2: fistful.IdentityNotFound ex2
            3: fistful.ForbiddenOperationCurrency ex3
            4: fistful.ForbiddenOperationAmount ex4
            5: fistful.OperationNotPermitted ex5
            6: p2p_transfer.NoResourceInfo ex6
        )

    p2p_transfer.P2PTransferState CreateTransfer(
        1: P2PTemplateID id
        2: P2PTemplateTransferParams params
        3: context.ContextSet context
    )
        throws (
            1: fistful.P2PTemplateNotFound ex1
            2: fistful.IdentityNotFound ex2
            3: fistful.ForbiddenOperationCurrency ex3
            4: fistful.ForbiddenOperationAmount ex4
            5: fistful.OperationNotPermitted ex5
            6: p2p_transfer.NoResourceInfo ex6
        )
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
    3: required P2PTemplateID        source
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
    void Repair(1: P2PTemplateID id, 2: RepairScenario scenario)
        throws (
            1: fistful.P2PTemplateNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
