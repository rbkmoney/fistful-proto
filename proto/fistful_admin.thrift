/**
 * Сервис кошельков
 */

namespace java com.rbkmoney.fistful_admin
namespace erlang fistful_admin

include "base.thrift"
include "context.thrift"
include "cashflow.thrift"
include "fistful.thrift"
include "transfer.thrift"

typedef fistful.AccountID AccountID
typedef fistful.SourceID SourceID
typedef fistful.DestinationID DestinationID
typedef fistful.DepositID DepositID
typedef fistful.RevertID RevertID
typedef fistful.AdjustmentID AdjustmentID
typedef fistful.WithdrawalID WithdrawalID
typedef fistful.IdentityID IdentityID
typedef fistful.WalletID WalletID
typedef fistful.Amount Amount
typedef fistful.SourceName SourceName

typedef base.CurrencyRef CurrencyRef
typedef base.Cash DepositBody
typedef base.CashRange CashRange

struct SourceParams {
    5: required SourceID                id
    1: required SourceName              name
    2: required IdentityID              identity_id
    3: required CurrencyRef             currency
    4: required fistful.SourceResource  resource

    99: optional context.ContextSet     context
}

struct DepositParams {
    4: required DepositID        id
    1: required SourceID         source
    2: required WalletID         destination
    3: required DepositBody      body

    99: optional context.ContextSet    context
}

struct RevertParams {
    1: required RevertID        id
    2: required Target          target

    3: optional base.Cash       body
    4: optional string          reason
}

struct Revert {
    1: required RevertID                    id
    2: required Target                      target
    3: required transfer.TransferStatus     status

    4: optional base.Cash                   body
    5: optional base.DataRevision           domain_revision
    6: optional base.PartyRevision          party_revision
    7: optional string                      reason
}

struct Target {
    1: required base.ID                     root_id
    2: required transfer.TransferType       root_type
    3: required base.ID                     target_id
}

struct AdjustmentParams {
    1: required AdjustmentID            id
    2: required Target                  target

    3: optional transfer.TransferStatus target_status
    4: optional base.DataRevision       domain_revision
    5: optional cashflow.FinalCashFlow  new_cash_flow
    6: optional string                  reason
}

struct Adjustment {
    1: required AdjustmentID            id
    2: required Target                  target
    3: required transfer.TransferStatus status

    4: optional cashflow.FinalCashFlow  new_cash_flow
    5: optional cashflow.FinalCashFlow  old_cash_flow_inverse
    6: optional transfer.TransferStatus target_status
    7: optional base.DataRevision       domain_revision
    8: optional base.PartyRevision      party_revision
    9: optional string                  reason
}

service FistfulAdmin {

    fistful.Source CreateSource (1: SourceParams params)
        throws (
            1: fistful.IdentityNotFound ex1
            2: fistful.CurrencyNotFound ex2
        )

    fistful.Source GetSource (1: SourceID id)
        throws (1: fistful.SourceNotFound ex1)

    fistful.Deposit CreateDeposit (1: DepositParams params)
        throws (
            1: fistful.SourceNotFound         ex1
            2: fistful.DestinationNotFound    ex2
            3: fistful.SourceUnauthorized     ex3
            4: fistful.DepositCurrencyInvalid ex4
            5: fistful.DepositAmountInvalid   ex5
        )

    fistful.Deposit GetDeposit (1: DepositID id)
        throws (1: fistful.DepositNotFound ex1)

    Revert CreateRevert (1: RevertParams params)
        throws (
            1: fistful.TransferNotFound         ex1
            2: fistful.CurrencyInvalid          ex2
            3: fistful.AmountInvalid            ex3
            4: fistful.OperationNotPermitted    ex4
        )

    Revert GetRevert (1: Target target)
        throws (1: fistful.TransferNotFound     ex1)


    Adjustment CreateAdjustment (1: AdjustmentParams params)
        throws (
            1: fistful.TransferNotFound         ex1
            2: fistful.OperationNotPermitted    ex2
        )

    Adjustment GetAdjustment (1: Target target)
        throws (1: fistful.TransferNotFound     ex1)

    Adjustment CaptureAdjustment (1: Target target)
        throws (
            1: fistful.TransferNotFound         ex1
            2: fistful.OperationNotPermitted    ex2
        )

    Adjustment CancelAdjustment (1: Target target)
        throws (
            1: fistful.TransferNotFound         ex1
            2: fistful.OperationNotPermitted    ex2
        )
}
