/**
 * Корректировка ввода
 */

namespace java   com.rbkmoney.fistful.deposit.adjustment
namespace erlang dep_adj

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"
include "transfer.thrift"
include "deposit_status.thrift"

typedef fistful.AdjustmentID    AdjustmentID
typedef base.ExternalID         ExternalID
typedef deposit_status.Status   TargetStatus

struct Adjustment {
    1: required AdjustmentID        id
    2: required ChangesPlan         changes_plan
    3: required base.Timestamp      created_at
    4: required base.DataRevision   domain_revision
    5: required base.PartyRevision  party_revision
    6: optional ExternalID          external_id
}

struct AdjustmentParams {
     1: required AdjustmentID        id
     2: required ChangeRequest       change
     3: optional ExternalID          external_id
}

struct AdjustmentState {
    1: required Adjustment adjustment
    2: required Status status
}

union Status {
    1: Pending pending
    2: Succeeded succeeded
}

struct Pending {}
struct Succeeded {}

union Change {
    1: CreatedChange     created
    2: StatusChange      status_changed
    3: TransferChange    transfer
}

struct CreatedChange {
    1: required Adjustment adjustment
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct ChangesPlan {
    1: optional CashFlowChangePlan new_cash_flow
    2: optional StatusChangePlan new_status
}

struct CashFlowChangePlan {
    1: required cashflow.FinalCashFlow old_cash_flow_inverted
    2: required cashflow.FinalCashFlow new_cash_flow
}

struct StatusChangePlan {
    1: required TargetStatus new_status
}

union ChangeRequest {
    1: ChangeStatusRequest change_status
}

struct ChangeStatusRequest {
    1: required TargetStatus new_status
}
