/**
 * Сервис кошельков
 */

namespace java com.rbkmoney.fistful
namespace erlang fistful

include "context.thrift"

typedef string ID
typedef ID SourceID
typedef ID DepositID
typedef ID IdentityID
typedef ID WalletID
typedef string CurrencySymbolicCode
typedef i64 Amount
typedef string SourceName

struct SourceResource { 1: optional string details }

enum SourceStatus {
    unauthorized = 1
    authorized   = 2
}

struct DepositBody {
    1: required Amount          amount
    2: required CurrencyRef     currency
}

struct CurrencyRef { 1: required CurrencySymbolicCode symbolic_code }

union DepositStatus {
    1: DepositStatusPending      pending
    2: DepositStatusSucceeded    succeeded
    3: DepositStatusFailed       failed
}

struct DepositStatusPending      {}
struct DepositStatusSucceeded    {}
struct DepositStatusFailed       { 1: optional string details }

struct SourceParams {
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

exception IdentityNotFound       {}
exception CurrencyNotFound       {}
exception SourceNotFound         {}
exception DestinationNotFound    {}
exception DepositNotFound        {}
exception SourceUnauthorized     {}

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
            1: SourceNotFound       ex1
            2: DestinationNotFound  ex2
            3: SourceUnauthorized   ex3
        )

    Deposit GetDeposit (1: DepositID id)
        throws (1: DepositNotFound ex1)

}
