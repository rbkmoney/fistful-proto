/**
 * Переводы
 */

namespace java   com.rbkmoney.fistful.p2p_transfer
namespace erlang p2p_transfer

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"
include "transfer.thrift"
include "p2p_adjustment.thrift"
include "p2p_status.thrift"
include "limit_check.thrift"

typedef base.ID                  SessionID
typedef base.ObjectID            ProviderID
typedef base.EventID             EventID
typedef fistful.P2PTransferID    P2PTransferID
typedef fistful.AdjustmentID     AdjustmentID
typedef fistful.IdentityID       IdentityID
typedef base.ExternalID          ExternalID
typedef p2p_status.Status        Status
typedef base.EventRange          EventRange
typedef base.Resource            Resource
typedef base.ContactInfo         ContactInfo

/// Domain

struct P2PTransfer {
    1: required IdentityID          owner
    2: required Sender              sender
    3: required Receiver            receiver
    4: required base.Cash           body
    5: required Status              status
    6: required base.Timestamp      created_at
    7: required base.DataRevision   domain_revision
    8: required base.PartyRevision  party_revision
    9: required base.Timestamp      operation_timestamp
    10: optional P2PQuote           quote
    11: optional ExternalID         external_id
    12: optional base.Timestamp     deadline
    13: optional base.ClientInfo    client_info
}

/// Пока используется как признак того, что операция была проведена по котировке
struct P2PQuote {}

union Sender {
    1: RawResource resource
}

union Receiver {
    1: RawResource resource
}

struct RawResource {
    1: required Resource resource
    2: required ContactInfo contact_info
}

struct Event {
    1: required EventID              event
    2: required base.Timestamp       occured_at
    3: required Change               change
}

union Change {
    1: CreatedChange       created
    2: StatusChange        status_changed
    3: ResourceChange      resource
    4: RiskScoreChange     risk_score
    5: RouteChange         route
    6: TransferChange      transfer
    7: SessionChange       session
    8: AdjustmentChange    adjustment
}

struct CreatedChange {
    1: required P2PTransfer p2p_transfer
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct AdjustmentChange {
    1: required AdjustmentID id
    2: required p2p_adjustment.Change payload
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

struct SessionFinished {
    1: required SessionResult result
}

union SessionResult {
    1: SessionSucceeded succeeded
    2: SessionFailed    failed
}

struct SessionSucceeded {}

struct SessionFailed {
    1: required base.Failure failure
}

struct RouteChange {
    1: required Route route
}

struct Route {
    1: required ProviderID provider_id
}

struct ResourceChange {
    1: required ResourcePayload payload
}

union ResourcePayload {
    1: ResourceGot got
}

struct ResourceGot {
    1: required Resource sender
    2: required Resource receiver
}

struct RiskScoreChange {
    1: required RiskScore score
}

enum RiskScore {
    low = 1
    high = 100
    fatal = 9999
}

/// Event sink

struct EventSinkPayload {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp       occured_at
    3: required list<Change>         changes
}

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required P2PTransferID        source
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
    1: required list<Change>           events
    2: optional repairer.ComplexAction action
}

service Repairer {
    void Repair(1: P2PTransferID id, 2: RepairScenario scenario)
        throws (
            1: fistful.P2PNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
