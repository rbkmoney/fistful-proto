/**
 * Владельцы
 */

namespace java   com.rbkmoney.fistful.identity
namespace erlang idnt

include "base.thrift"
include "context.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairer.thrift"

/// Domain

typedef base.ID IdentityID
typedef base.ID ChallengeID
typedef base.ID IdentityToken
typedef base.ID PartyID
typedef base.ID ContractID
typedef base.ID ProviderID
typedef base.ID ClassID
typedef base.ID LevelID
typedef base.ID ChallengeClassID
typedef base.ExternalID ExternalID
typedef context.ContextSet ContextSet
typedef base.EventRange EventRange
typedef base.Timestamp Timestamp
typedef fistful.Blocking Blocking

struct IdentityParams {
    1: required PartyID     party
    2: required ProviderID  provider
    3: required ClassID     cls
    4: optional ExternalID  external_id

    99: optional ContextSet context
}

struct Identity {
    1:  required PartyID     party
    2:  required ProviderID  provider
    3:  required ClassID     cls
    4:  optional ContractID  contract
    5:  optional ExternalID  external_id
    6:  optional IdentityID  id
    7:  optional ChallengeID effective_challenge
    8:  optional Blocking    blocking
    9:  optional LevelID     level
    10: optional Timestamp   created_at

    99: optional ContextSet  context
}

struct IdentityEvent {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp       occured_at
    3: required Change               change
}

struct Challenge {
    1: required ChallengeClassID     cls
    2: optional list<ChallengeProof> proofs
    3: optional ChallengeID          id
    4: optional ChallengeStatus      status
}

struct ChallengeParams {
    1: required ChallengeID          id
    2: required ChallengeClassID     cls
    3: required list<ChallengeProof> proofs
}

union ChallengeStatus {
    1: ChallengePending   pending
    2: ChallengeCancelled cancelled
    3: ChallengeCompleted completed
    4: ChallengeFailed    failed
}

struct ChallengePending   {}
struct ChallengeCancelled {}

struct ChallengeCompleted {
    1: required ChallengeResolution resolution
    2: optional base.Timestamp      valid_until
}

struct ChallengeFailed {
    // TODO
}

enum ChallengeResolution {
    approved
    denied
}

enum ProofType {
    rus_domestic_passport
    rus_retiree_insurance_cert
}

struct ChallengeProof {
    1: optional ProofType     type
    2: optional IdentityToken token
}

service Management {

    Identity Create (
        1: IdentityID     id
        2: IdentityParams params)
        throws (
            1: fistful.ProviderNotFound      ex1
            2: fistful.IdentityClassNotFound ex2
            3: fistful.PartyInaccessible     ex3
        )

    Identity Get (1: IdentityID id)
        throws (
            1: fistful.IdentityNotFound ex1
        )

    Challenge StartChallenge (
        1: IdentityID      id
        2: ChallengeParams params)
        throws (
            1: fistful.IdentityNotFound        ex1
            2: fistful.ChallengePending        ex2
            3: fistful.ChallengeClassNotFound  ex3
            4: fistful.ChallengeLevelIncorrect ex4
            5: fistful.ChallengeConflict       ex5
            6: fistful.ProofNotFound           ex6
            7: fistful.ProofInsufficient       ex7
            8: fistful.PartyInaccessible       ex8
        )

    list<Challenge> GetChallenges(1: IdentityID  id)
        throws (
            1: fistful.IdentityNotFound  ex1
        )

    list<IdentityEvent> GetEvents (
        1: IdentityID identity_id
        2: EventRange range)
        throws (
            1: fistful.IdentityNotFound ex1
        )
}

/// Wallet events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Identity        created
    2: LevelID         level_changed
    3: ChallengeChange identity_challenge
    4: ChallengeID     effective_challenge_changed
}

struct ChallengeChange {
    1: required ChallengeID            id
    2: required ChallengeChangePayload payload
}

union ChallengeChangePayload {
    1: Challenge       created
    2: ChallengeStatus status_changed
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required IdentityID           source
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
    void Repair(1: IdentityID id, 2: RepairScenario scenario)
        throws (
            1: fistful.IdentityNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
