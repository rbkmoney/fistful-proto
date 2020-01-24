/**
 * Кошельки
 */

namespace java   com.rbkmoney.fistful.wallet
namespace erlang wlt

include "base.thrift"
include "fistful.thrift"
include "account.thrift"
include "identity.thrift"
include "eventsink.thrift"
include "repairer.thrift"
include "context.thrift"

/// Domain

typedef fistful.WalletID WalletID
typedef account.Account Account
typedef base.ExternalID ExternalID
typedef base.ID ContractID
typedef base.Timestamp Timestamp
typedef base.CurrencySymbolicCode CurrencySymbolicCode
typedef account.AccountParams AccountParams

/// Wallet status
enum Blocking {
    unblocked
    blocked
}

struct WalletParams {
    1: required string         name
    2: required AccountParams  account_params

    98: optional ExternalID          external_id
    99: optional context.ContextSet  context
}

struct Wallet {
    1: optional string     name
    2: optional ExternalID external_id
    3: optional WalletID   id
    4: optional Blocking   blocking
    5: optional Account    account
    6: optional Timestamp  created_at

    99: optional context.ContextSet context
}

/// Wallet events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: Wallet           created
    2: AccountChange    account
}

union AccountChange {
    1: Account          created
}

///

service Management {
    Wallet Create (
        1: WalletID id
        2: WalletParams params)
        throws (
            1: fistful.IdentityNotFound     ex1
            2: fistful.CurrencyNotFound     ex2
            3: fistful.PartyInaccessible    ex3
            4: fistful.IDExists             ex4
        )

    Wallet Get (1: WalletID id)
        throws (1: fistful.WalletNotFound ex1)
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required WalletID             source
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
    void Repair(1: WalletID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WalletNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
