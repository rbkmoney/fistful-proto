/**
 * Владельцы
 */

namespace java   com.rbkmoney.fistful.identity
namespace erlang idnt

include "base.thrift"
include "context.thrift"
include "fistful.thrift"
include "eventsink.thrift"

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
typedef eventsink.EventRange EventRange

struct IdentityParams {
    1: required PartyID     party
    2: required ProviderID  provider
    3: required ClassID     cls
    4: optional ExternalID  external_id

    99: optional ContextSet context
}

struct IdentityState {
    1: IdentityID id
    2: PartyID    party
    3: ClassID    cls
    4: ProviderID provider
    5: ExternalID external_id
    6: LevelID    level
    7: ContractID contract

    99: optional ContextSet context
}

struct Identity {
    1: required PartyID    party
    2: required ProviderID provider
    3: required ClassID    cls
    4: optional ContractID contract
    5: optional ExternalID external_id
}

struct IdentityEvent {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp       occured_at
    3: required Change               change
}

struct ChallengeState {
    1: required ChallengeID          id
    2: required list<ChallengeProof> proofs
    3: required ChallengeClassID     cls
    4: required ChallengeStatus      status
}

struct Challenge {
    1: required ChallengeClassID     cls
    2: optional list<ChallengeProof> proofs
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
    1: ProofType     type
    2: IdentityToken token
}


service Management {

    IdentityState Create (
        1: required IdentityID     id
        2: required IdentityParams params)
        throws (
            1: fistful.ProviderNotFound      ex1
            2: fistful.IdentityClassNotFound ex2
            3: fistful.PartyInaccessible     ex3
        )

    IdentityState Get (1: required IdentityID id)
        throws (
            1: fistful.IdentityNotFound ex1
        )

    ChallengeID StartChallenge (
        1: required IdentityID      id
        2: required ChallengeParams params)
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

    list<ChallengeState> GetChallenges(
        1: required IdentityID  id
    ) throws (
        1: fistful.IdentityNotFound  ex1
    )

    list<IdentityEvent> GetEvents (
        1: required IdentityID identity_id
        2: required EventRange range)
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

