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

/** Условия запрещают проводить операцию с такой валютой */
exception ForbiddenOperationCurrency {
    1: required CurrencyRef currency
    2: required set<CurrencyRef> allowed_currencies
}

/** Условия запрещают проводить операцию с такой суммой */
exception ForbiddenOperationAmount {
    1: required base.Cash amount
    2: required base.CashRange allowed_range
}

/** Операцию с такой суммой невозможно провести */
exception InvalidOperationAmount {
    1: required base.Cash amount
}

exception OperationNotPermitted { 1: optional string details }
exception P2PNotFound        {}
exception P2PSessionNotFound {}
