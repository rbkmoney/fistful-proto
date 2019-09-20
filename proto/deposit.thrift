/**
 * Вводы
 */

namespace java   com.rbkmoney.fistful.deposit
namespace erlang deposit

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "transfer.thrift"
include "deposit_revert.thrift"
include "deposit_adjustment.thrift"
include "deposit_status.thrift"
include "limit_check.thrift"
include "repairer.thrift"

typedef fistful.DepositID       DepositID
typedef fistful.AdjustmentID    AdjustmentID
typedef fistful.DepositRevertID RevertID
typedef fistful.WalletID        WalletID
typedef fistful.SourceID        SourceID
typedef base.ExternalID         ExternalID
typedef deposit_status.Status   Status

struct Deposit {
    5: required DepositID      id
    1: required WalletID       wallet
    2: required SourceID       source
    3: required base.Cash      body
    6: optional Status         status
    4: optional ExternalID     external_id
}

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

union Change {
    1: CreatedChange    created
    2: StatusChange     status_changed
    3: TransferChange   transfer
    4: RevertChange     revert
    5: AdjustmentChange adjustment
    6: LimitCheckChange limit_check
}

struct CreatedChange {
    1: required Deposit deposit
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct RevertChange {
    1: required RevertID id
    2: required deposit_revert.Change payload
}

struct AdjustmentChange {
    1: required AdjustmentID id
    2: required deposit_adjustment.Change payload
}

struct LimitCheckChange {
    1: required limit_check.Details details
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required DepositID            source
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
    1: required list<Change>            events
    2: optional repairer.ComplexAction  action
}

service Repairer {
    void Repair(1: DepositID id, 2: RepairScenario scenario)
        throws (
            1: fistful.DepositNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
