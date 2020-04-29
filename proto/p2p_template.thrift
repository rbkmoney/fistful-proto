/**
 * Шаблоны переводов
 */

namespace java   com.rbkmoney.fistful.p2p_template
namespace erlang p2p_template

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"

/// Domain

typedef fistful.P2PTemplateID P2PTemplateID
typedef fistful.IdentityID IdentityID

typedef base.ExternalID ExternalID
typedef base.Timestamp Timestamp
typedef fistful.Blocking Blocking

struct P2PTemplate {
    1: required P2PTemplateID id
    2: required IdentityID identity_id
    3: required Blocking blocking
    4: required Timestamp created_at
    5: required base.DataRevision domain_revision
    6: required base.PartyRevision party_revision
    7: required P2PTemplateFields fields
    8: optional ExternalID external_id
}

struct P2PTemplateFields {
    1: optional P2PTemplateFieldBody body
    2: optional P2PTemplateFieldMetadata metadata
}

struct P2PTemplateFieldBody {
    1: required base.Cash value
}

struct P2PTemplateFieldMetadata {
    1: required context.ContextSet value
}

/// P2PTemplate events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: P2PTemplate created
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required P2PTemplateID        source
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
    void Repair(1: P2PTemplateID id, 2: RepairScenario scenario)
        throws (
            1: fistful.P2PTemplateNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
