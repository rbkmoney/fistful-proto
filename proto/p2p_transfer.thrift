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
include "cashflow.thrift"
include "transfer.thrift"
include "p2p_adjustment.thrift"
include "p2p_status.thrift"
include "limit_check.thrift"

typedef base.ID                  SessionID
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
    15: required P2PTransferID id
    1: required IdentityID owner
    2: required Sender sender
    3: required Receiver receiver
    4: required base.Cash body
    5: required Status status
    6: required base.Timestamp created_at
    7: required base.DataRevision domain_revision
    8: required base.PartyRevision party_revision
    9: required base.Timestamp operation_timestamp
    10: optional P2PQuoteState quote
    11: optional ExternalID external_id
    12: optional base.Timestamp deadline
    13: optional base.ClientInfo client_info
    14: optional context.ContextSet metadata
}

struct P2PTransferParams {
    1: required P2PTransferID id
    2: required Sender sender
    3: required Receiver receiver
    4: required base.Cash body
    5: optional ExternalID external_id
    6: optional P2PQuote quote
}

struct P2PTransferState {
    15: required P2PTransferID id
    1: required IdentityID owner
    2: required Sender sender
    3: required Receiver receiver
    4: required base.Cash body
    5: required Status status
    6: required base.Timestamp created_at
    7: required base.DataRevision domain_revision
    8: required base.PartyRevision party_revision
    9: required base.Timestamp operation_timestamp
    10: optional P2PQuoteState quote
    11: optional ExternalID external_id
    12: optional base.Timestamp deadline
    13: optional base.ClientInfo client_info
    14: optional context.ContextSet metadata

    /** Контекст сущности заданный при её старте */
    16: required context.ContextSet context

    /**
      * Набор проводок, который отражает предполагаемое движение денег между счетами.
      * Может меняться в процессе прохождения операции или после применения корректировок.
      */
    17: required cashflow.FinalCashFlow effective_final_cash_flow

    /** Текущий действующий маршрут */
    18: optional Route effective_route

    /** Перечень сессий взаимодействия с провайдером */
    19: required list<SessionState> sessions

    /** Перечень корректировок */
    20: required list<p2p_adjustment.AdjustmentState> adjustments
}

struct SessionState {
    1: required SessionID id
    2: optional SessionResult result
}

struct P2PQuoteParams {
    1: required base.Cash body
    2: required IdentityID identity_id
    3: required Resource sender
    4: required Resource receiver
}

struct P2PQuoteState {
    1: optional base.Fees fees
}

struct P2PQuote {
    1: required base.Cash body
    2: required base.Timestamp created_at
    3: required base.Timestamp expires_on
    4: required base.DataRevision domain_revision
    5: required base.PartyRevision party_revision
    6: required IdentityID identity_id
    7: required Resource sender
    8: required Resource receiver
    9: optional base.Fees fees
}

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

struct TimestampedChange {
    1: required base.Timestamp       occured_at
    2: required Change               change
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
    2: required fistful.ProviderID provider_id
    3: optional fistful.TerminalID terminal_id

    // deprecated
    1: optional base.ObjectID provider_id_legacy
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

exception InvalidP2PTransferStatus {
    1: required Status p2p_status
}

exception ForbiddenStatusChange {
    1: required Status target_status
}

exception AlreadyHasStatus {
    1: required Status p2p_status
}

exception AnotherAdjustmentInProgress {
    1: required AdjustmentID another_adjustment_id
}

service Management {

    P2PQuote GetQuote(
        1: P2PQuoteParams params
    )
        throws (
            1: fistful.IdentityNotFound ex1
            2: fistful.ForbiddenOperationCurrency ex2
            3: fistful.ForbiddenOperationAmount ex3
            4: fistful.OperationNotPermitted ex4
        )

    P2PTransferState Create(
        1: P2PTransferParams params
        2: context.ContextSet context
    )
        throws (
            1: fistful.IdentityNotFound ex1
            2: fistful.ForbiddenOperationCurrency ex2
            3: fistful.ForbiddenOperationAmount ex3
            4: fistful.OperationNotPermitted ex4
        )

    P2PTransferState Get(
        1: P2PTransferID id
        2: EventRange range
    )
        throws (
            1: fistful.P2PNotFound ex1
        )

    context.ContextSet GetContext(1: P2PTransferID id)
        throws (
            1: fistful.P2PNotFound ex1
        )

    list<Event> GetEvents(
        1: P2PTransferID id
        2: EventRange range
    )
        throws (
            1: fistful.P2PNotFound ex1
        )

    p2p_adjustment.AdjustmentState CreateAdjustment(
        1: P2PTransferID id
        2: p2p_adjustment.AdjustmentParams params
    )
        throws (
            1: fistful.P2PNotFound ex1
            2: InvalidP2PTransferStatus ex2
            3: ForbiddenStatusChange ex3
            4: AlreadyHasStatus ex4
            5: AnotherAdjustmentInProgress ex5
        )
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
