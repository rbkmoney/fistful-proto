/**
 * Сессии
 */

namespace java   com.rbkmoney.fistful.withdrawal_session
namespace erlang wthd_session

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "destination.thrift"
include "msgpack.thrift"
include "context.thrift"

typedef fistful.WithdrawalID WithdrawalID
typedef base.ID SessionID
typedef msgpack.Value AdapterState
typedef base.Resource Resource
typedef base.ID IdentityToken
typedef base.ID ChallengeID
typedef base.EventRange EventRange

/// Domain

/**
 * Структура, которую вернул нам адаптер в damsel/withdrawals_provider_adapter.
 */
struct Quote {
    1: required base.Cash cash_from
    2: required base.Cash cash_to
    3: required base.Timestamp created_at
    4: required base.Timestamp expires_on
    6: optional msgpack.Value quote_data

    // deprecated
    5: optional context.ContextSet quote_data_legacy
}

struct SessionState {
    1: required SessionID id
    2: required Withdrawal withdrawal
    3: required Route route
    4: optional context.ContextSet context

    // deprecated
    5: optional SessionStatus status
}

struct Session {
    1: required SessionID id
    3: required Withdrawal withdrawal
    6: required Route route

    // deprecated
    2: optional SessionStatus status
    4: optional base.ID provider_legacy
    5: optional base.ID terminal_legacy
}

union SessionStatus {
    1: SessionActive    active
    2: SessionFinished  finished
}

struct SessionActive {}
struct SessionFinished {
    1: SessionFinishedStatus status
}

union SessionFinishedStatus {
    1: SessionFinishedSuccess success
    2: SessionFinishedFailed  failed
}

struct SessionFinishedSuccess {}
struct SessionFinishedFailed {
    1: optional base.Failure failure
}

struct Withdrawal {
    1: required WithdrawalID            id
    2: required Resource                destination_resource
    3: required base.Cash               cash
    8: optional Identity                sender
    9: optional Identity                receiver
    6: optional SessionID               session_id
    7: optional Quote                   quote
}

struct Route {
    1: required fistful.ProviderID provider_id
    2: optional fistful.TerminalID terminal_id
}

struct Identity {
    1: required fistful.IdentityID identity_id
    2: optional Challenge effective_challenge
}

struct Challenge {
    1: optional ChallengeID id
    2: optional list<ChallengeProof> proofs
}

enum ProofType {
    rus_domestic_passport
    rus_retiree_insurance_cert
}

struct ChallengeProof {
    1: optional ProofType     type
    2: optional IdentityToken token
}

struct Callback {
    1: required base.Tag tag
}

/// Session events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

struct TimestampedChange {
    1: required base.Timestamp       occured_at
    2: required Change               change
}

union Change {
    1: Session        created
    2: AdapterState   next_state
    3: SessionResult  finished
    4: CallbackChange callback
}

union SessionResult {
    1: SessionResultSuccess  success
    2: SessionResultFailed   failed
}

struct SessionResultSuccess {
    1: required base.TransactionInfo trx_info
}

struct SessionResultFailed {
    1: required base.Failure failure
}

struct CallbackChange {
    1: required base.Tag tag
    2: required CallbackChangePayload payload
}

union CallbackChangePayload {
    1: CallbackCreatedChange  created
    2: CallbackStatusChange   status_changed
    3: CallbackResultChange   finished
}

struct CallbackCreatedChange {
    1: required Callback callback
}

struct CallbackStatusChange {
    1: required CallbackStatus status
}

union CallbackStatus {
    1: CallbackStatusPending pending
    2: CallbackStatusSucceeded succeeded
}

struct CallbackStatusPending {}
struct CallbackStatusSucceeded {}

struct CallbackResultChange {
    1: required binary payload
}

///

service Management {
    SessionState Get (
        1: SessionID id
        2: EventRange range
    )
        throws (1: fistful.WithdrawalSessionNotFound ex1)

    context.ContextSet GetContext(
        1: SessionID id
    )
        throws (
            1: fistful.WithdrawalSessionNotFound ex1
        )
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required SessionID            source
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
    2: SetResultRepair set_session_result
}

struct AddEventsRepair {
    1: required list<Event>             events
    2: optional repairer.ComplexAction  action
}

struct SetResultRepair {
    1: required SessionResult           result
}

service Repairer {
    void Repair(1: SessionID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WithdrawalSessionNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
