/**
 * Переводы
 */

namespace java   com.rbkmoney.fistful.p2p
namespace erlang p2p

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"
include "transfer.thrift"
include "p2p_adjustment.thrift"
include "p2p_status.thrift"
include "limit_check.thrift"
//include "source.thrift"
//include "destination.thrift"

typedef base.ID                  SessionID
typedef base.ID                  ProviderID
typedef base.EventID             EventID
typedef fistful.P2PID            P2PID
typedef fistful.AdjustmentID     AdjustmentID
typedef fistful.IdentityID       IdentityID
typedef fistful.DestinationID    DestinationID
typedef fistful.SourceID         SourceID
typedef base.ExternalID          ExternalID
typedef p2p_status.Status        Status
typedef base.EventRange          EventRange
typedef base.Resource            Resource
//typedef base.ContactInfo         ContactInfo
//typedef destination.Destination  Destination
//typedef source.Source            Source

/// Domain

struct P2P {
    1: required IdentityID     owner
    1: required P2PSource      source
    2: required P2PDestination destination
    3: required base.Cash      body
    4: optional ExternalID     external_id
    6: optional Status         status
}

union P2PSource {
    1: P2PResourceRaw raw
    //2: Source source
}

union P2PDestination {
    1: P2PResourceRaw raw
    //2: Destination destination
}

struct P2PResourceRaw {
    1: required Resource resource
    //2: required ContactInfo contact_info
}

struct Event {
    1: required EventID              event
    2: required base.Timestamp       occured_at
    3: required Change               change
}

union Change {
    1: CreatedChange       created
    2: StatusChange        status_changed
    6: ResourceChange      resource
    5: RouteChange         route
    3: TransferChange      transfer
    8: LimitCheckChange    limit_check
    4: SessionChange       session
    7: AdjustmentChange    adjustment
    9: RiskScoreChange     risk_score
}

struct CreatedChange {
    1: required P2P p2p
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

struct LimitCheckChange {
    1: required limit_check.Details details
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

struct SessionSucceeded {
    1: required base.TransactionInfo trx_info
}

struct SessionFailed {
    1: required base.Failure failure
}

struct RouteChange {
    1: required Route route
}

struct Route {
    1: required ProviderID provider_id
}

union ResourceChange {
    1: ResourceGot got
}

struct ResourceGot {
    1: required Resource resource
}

struct RiskScoreChange {
    1: required map<RiskType, RiskScore> scores
}

enum RiskScore {
    low = 1
    high = 100
    fatal = 9999
}

typedef base.ID RiskType

/// Event sink

struct EventSinkPayload {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp       occured_at
    3: required list<Change>         changes
}

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required P2PID                source
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
    void Repair(1: P2PID id, 2: RepairScenario scenario)
        throws (
            1: fistful.P2PNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
