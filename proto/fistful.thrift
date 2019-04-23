/**
 * Сервис кошельков
 */

namespace java com.rbkmoney.fistful
namespace erlang fistful

include "base.thrift"
include "context.thrift"

typedef base.ID ID
typedef ID AccountID
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

struct Source {
    1: required SourceID         id
    2: required SourceName       name
    3: required IdentityID       identity_id
    4: required CurrencyRef      currency
    5: required SourceResource   resource
    6: required SourceStatus     status

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
