/**
 * Владельцы
 */

namespace java   com.rbkmoney.fistful.identity
namespace erlang idnt

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"

/// Domain

typedef base.ID IdentityID
typedef base.ID ChallengeID

typedef base.ID PartyID
typedef base.ID ContractID
typedef base.ID ProviderID
typedef base.ID ClassID
typedef base.ID LevelID
typedef base.ID ChallengeClassID
typedef base.ExternalID ExternalID

struct Identity {
    1: required PartyID         party
    2: required ProviderID      provider
    3: required ClassID         cls
    4: optional ContractID      contract
    5: optional ExternalID      external_id
}

struct Challenge {
    1: required ChallengeClassID     cls
    2: optional list<ChallengeProof> proofs
}

union ChallengeStatus {
    1: ChallengePending   pending
    2: ChallengeCancelled cancelled
    3: ChallengeCompleted completed
    4: ChallengeFailed    failed
}

struct ChallengePending {}
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

struct ChallengeProof {
    // TODO
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

