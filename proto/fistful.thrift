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
typedef ID RepositID
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

union RepositStatus {
    1: RepositStatusPending      pending
    2: RepositStatusSucceeded    succeeded
    3: RepositStatusFailed       failed
}

struct RepositStatusPending      {}
struct RepositStatusSucceeded    {}
struct RepositStatusFailed       { 1: optional string details }

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
    6: optional list<Reposit>    reposits

    99: optional context.ContextSet    context
}

struct RevertDepositParams {
    1: required DepositID        id
    2: required DepositBody      body
    3: optional string           reason
}

struct Reposit {
    1: required RepositID           id
    2: required DepositID           deposit
    3: required WalletID            source
    4: required SourceID            destination
    5: required base.Cash           body
    6: required RepositStatus       status
    7: required base.Timestamp      created_at
    8: optional base.DataRevision   domain_revision
    9: optional base.PartyRevision  party_revision

    10: optional string             reason
}

exception IdentityNotFound          {}
exception CurrencyNotFound          {}
exception SourceNotFound            {}
exception DestinationNotFound       {}
exception DepositNotFound           {}
exception RepositNotFound           {}
exception RepositCurrencyInvalid    {}
exception RepositAmountInvalid      {}
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

    Reposit RevertDeposit (1: RevertDepositParams params)
        throws (
            1: DepositNotFound        ex1
            2: RepositCurrencyInvalid ex2
            3: RepositAmountInvalid   ex3
            4: OperationNotPermitted  ex4
        )

    Reposit GetReposit (1: DepositID deposit_id, 2: RepositID reposit_id)
        throws (
            1: DepositNotFound ex1
            2: RepositNotFound ex2
        )
}
