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
typedef ID DepositRevertID
typedef ID AdjustmentID
typedef ID WithdrawalID
typedef ID P2PTransferID
typedef ID IdentityID
typedef ID WalletID
typedef i64 Amount
typedef string SourceName

typedef base.CurrencyRef CurrencyRef
typedef base.Cash DepositBody
typedef base.CashRange CashRange

enum Blocking {
    unblocked
    blocked
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
exception OperationNotPermitted { 1: optional string details }
exception P2PNotFound        {}
exception P2PSessionNotFound {}
