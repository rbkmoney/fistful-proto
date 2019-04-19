/**
 * Сервис кошельков
 */

namespace java com.rbkmoney.fistful
namespace erlang fistful

include "base.thrift"
include "context.thrift"
include "cashflow.thrift"

typedef base.ID ID
typedef ID SourceID
typedef ID DestinationID
typedef ID DepositID
typedef ID RevertID
typedef ID AdjustmentID
typedef ID WithdrawalID
typedef ID IdentityID
typedef ID WalletID
typedef i64 Amount
typedef string SourceName

typedef base.CurrencyRef CurrencyRef
typedef base.Cash DepositBody
typedef base.CashRange CashRange

struct SourceResource { 1: optional string details }

enum SourceStatus {
    unauthorized = 1
    authorized   = 2
}

union DepositStatus {
    1: DepositStatusPending      pending
    2: DepositStatusSucceeded    succeeded
    3: DepositStatusFailed       failed
    4: DepositStatusReverted     reverted
}

struct DepositStatusPending      {}
struct DepositStatusSucceeded    {}
struct DepositStatusFailed       { 1: optional string details }
struct DepositStatusReverted     { 1: optional string details }

struct SourceParams {
    5: required SourceID         id
    1: required SourceName       name
    2: required IdentityID       identity_id
    3: required CurrencyRef      currency
    4: required SourceResource   resource

    99: optional context.ContextSet    context
}

struct Source {
    1: required SourceID         id
    2: required SourceName       name
    3: required IdentityID       identity_id
    4: required CurrencyRef      currency
    5: required SourceResource   resource
    6: required SourceStatus     status

    99: optional context.ContextSet    context
}

struct DepositParams {
    4: required DepositID        id
    1: required SourceID         source
    2: required WalletID         destination
    3: required DepositBody      body

    99: optional context.ContextSet    context
}

struct Deposit {
    1: required DepositID        id
    2: required SourceID         source
    3: required WalletID         destination
    4: required DepositBody      body
    5: required DepositStatus    status

    99: optional context.ContextSet    context
}

union TransferType {
    1: TransferDeposit     deposit
    2: TransferWithdrawal  withdrawal
    3: TransferRevert      revert
    4: TransferAdjustment  adjustment
}

struct TransferDeposit {}
struct TransferWithdrawal {}

union TransferRevert {
    1: TransferDepositRevert    deposit
    2: TransferAdjustmentRevert adjustment
}
struct TransferDepositRevert {}
struct TransferAdjustmentRevert {}

struct TransferAdjustment {}

union TransferStatus {
    1: TransferStatusPending      pending
    2: TransferStatusSucceeded    succeeded
    3: TransferStatusFailed       failed
    4: TransferStatusReverted     reverted
}

struct TransferStatusPending      {}
struct TransferStatusSucceeded    {}
struct TransferStatusFailed       { 1: optional string details }
struct TransferStatusReverted     { 1: optional string details }

struct RevertParams {
    1: required RevertID        id
    2: required Target          target

    3: optional base.Cash       body
    4: optional string          reason
}

struct Revert {
    1: required RevertID            id
    2: required Target              target
    3: required TransferStatus      status

    4: optional base.Cash           body
    5: optional base.DataRevision   domain_revision
    6: optional base.PartyRevision  party_revision
    7: optional string              reason
}

struct Target {
    1: required base.ID             root_id
    2: required TransferType        root_type
    3: required base.ID             target_id
}

struct AdjustmentParams {
    1: required AdjustmentID            id
    2: required Target                  target

    3: optional TransferStatus          target_status
    4: optional base.DataRevision       domain_revision
    5: optional cashflow.FinalCashFlow  new_cash_flow
    6: optional string                  reason
}

struct Adjustment {
    1: required AdjustmentID            id
    2: required Target                  target
    3: required TransferStatus          status

    4: optional cashflow.FinalCashFlow  new_cash_flow
    5: optional cashflow.FinalCashFlow  old_cash_flow_inverse
    6: optional TransferStatus          target_status
    7: optional base.DataRevision       domain_revision
    8: optional base.PartyRevision      party_revision
    9: optional string                  reason
}

exception IdentityNotFound          {}
exception CurrencyNotFound          {}
exception SourceNotFound            {}
exception DestinationNotFound       {}
exception DepositNotFound           {}
exception SourceUnauthorized        {}
exception DepositCurrencyInvalid    {}
exception DepositAmountInvalid      {}
exception PartyInaccessible         {}
exception ProviderNotFound          {}
exception IdentityClassNotFound     {}
exception ChallengeNotFound         {}
exception ChallengePending          {}
exception ChallengeClassNotFound    {}
exception ChallengeLevelIncorrect   {}
exception ChallengeConflict         {}
exception ProofNotFound             {}
exception ProofInsufficient         {}
exception WalletNotFound            {}
exception WithdrawalNotFound        {}
exception WithdrawalSessionNotFound {}
exception MachineAlreadyWorking     {}
exception IDExists                  {}
exception DestinationUnauthorized   {}
exception WithdrawalCurrencyInvalid {
    1: required CurrencyRef withdrawal_currency
    2: required CurrencyRef wallet_currency
}
exception WithdrawalCashAmountInvalid {
    1: required base.Cash      cash
    2: required base.CashRange range
}

exception OperationNotPermitted { 1: optional string    details }
exception TransferNotFound      { 1: optional base.ID   id }
exception CurrencyInvalid       {}
exception AmountInvalid         {}

service FistfulAdmin {

    Source CreateSource (1: SourceParams params)
        throws (
            1: IdentityNotFound ex1
            2: CurrencyNotFound ex2
        )

    Source GetSource (1: SourceID id)
        throws (1: SourceNotFound ex1)

    Deposit CreateDeposit (1: DepositParams params)
        throws (
            1: SourceNotFound         ex1
            2: DestinationNotFound    ex2
            3: SourceUnauthorized     ex3
            4: DepositCurrencyInvalid ex4
            5: DepositAmountInvalid   ex5
        )

    Deposit GetDeposit (1: DepositID id)
        throws (1: DepositNotFound ex1)

    Revert CreateRevert (1: RevertParams params)
        throws (
            1: TransferNotFound         ex1
            2: CurrencyInvalid          ex2
            3: AmountInvalid            ex3
            4: OperationNotPermitted    ex4
        )

    Revert GetRevert (1: Target target)
        throws (1: TransferNotFound     ex1)


    Adjustment CreateAdjustment (1: AdjustmentParams params)
        throws (
            1: TransferNotFound         ex1
            2: OperationNotPermitted    ex2
        )

    Adjustment GetAdjustment (1: Target target)
        throws (1: TransferNotFound     ex1)

    Adjustment CaptureAdjustment (1: Target target)
        throws (
            1: TransferNotFound         ex1
            2: OperationNotPermitted    ex2
        )

    Adjustment CancelAdjustment (1: Target target)
        throws (
            1: TransferNotFound         ex1
            2: OperationNotPermitted    ex2
        )
}
