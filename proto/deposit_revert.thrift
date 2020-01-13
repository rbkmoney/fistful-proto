/**
 * Возврат ввода
 */

namespace java   com.rbkmoney.fistful.deposit.revert
namespace erlang deposit_revert

include "base.thrift"
include "fistful.thrift"
include "transfer.thrift"
include "deposit_revert_adjustment.thrift"
include "deposit_revert_status.thrift"
include "limit_check.thrift"
include "cashflow.thrift"

typedef base.Failure            Failure
typedef fistful.DepositRevertID RevertID
typedef fistful.WalletID        WalletID
typedef fistful.SourceID        SourceID
typedef fistful.AdjustmentID    AdjustmentID
typedef base.ExternalID         ExternalID

typedef deposit_revert_status.Status Status

/// Domain

struct Revert {
     1: required RevertID            id
     2: required WalletID            wallet_id
     3: required SourceID            source_id
     4: required Status              status
     5: required base.Cash           body
     6: required base.Timestamp      created_at
     7: required base.DataRevision   domain_revision
     8: required base.PartyRevision  party_revision
     9: optional string              reason
    10: optional ExternalID          external_id
}

struct RevertParams {
    1: required RevertID             id
    2: required base.Cash            body
    3: optional string               reason
    4: optional ExternalID           external_id
}

struct RevertState {
    1: required Revert revert

    /**
      * Набор проводок, который отражает предполагаемое движение денег между счетами.
      * Может меняться в процессе прохождения операции или после применения корректировок.
      */
    2: required cashflow.FinalCashFlow effective_final_cash_flow

    /** Перечень корректировок */
    3: required list<deposit_revert_adjustment.AdjustmentState> adjustments
}

union Change {
    1: CreatedChange     created
    2: StatusChange      status_changed
    3: LimitCheckChange  limit_check
    4: TransferChange    transfer
    5: AdjustmentChange  adjustment
}

struct CreatedChange {
    1: required Revert revert
}

struct StatusChange {
    1: required Status status
}

struct LimitCheckChange {
    1: required limit_check.Details details
}

struct TransferChange {
    1: required transfer.Change payload
}

struct AdjustmentChange {
    1: required AdjustmentID id
    2: required deposit_revert_adjustment.Change payload
}
