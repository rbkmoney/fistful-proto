/**
 * Сервис кошельков
 */

namespace java com.rbkmoney.fistful.admin
namespace erlang ff_admin

include "base.thrift"
include "fistful.thrift"
include "context.thrift"
include "source.thrift"
include "deposit.thrift"

typedef fistful.AccountID AccountID
typedef fistful.SourceID SourceID
typedef fistful.DestinationID DestinationID
typedef fistful.DepositID DepositID
typedef fistful.DepositRevertID DepositRevertID
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
    5: required SourceID         id
    1: required SourceName       name
    2: required IdentityID       identity_id
    3: required CurrencyRef      currency
    4: required source.Resource  resource
}

struct DepositParams {
    4: required DepositID        id
    1: required SourceID         source
    2: required WalletID         destination
    3: required DepositBody      body
}

exception DepositCurrencyInvalid    {}
exception DepositAmountInvalid      {}

service FistfulAdmin {

    source.Source CreateSource (1: SourceParams params)
        throws (
            1: fistful.IdentityNotFound ex1
            2: fistful.CurrencyNotFound ex2
        )

    source.Source GetSource (1: SourceID id)
        throws (
            1: fistful.SourceNotFound ex1
        )

    deposit.Deposit CreateDeposit (1: DepositParams params)
        throws (
            1: fistful.SourceNotFound         ex1
            2: fistful.WalletNotFound         ex2
            3: fistful.SourceUnauthorized     ex3
            4: DepositCurrencyInvalid ex4
            5: DepositAmountInvalid   ex5
        )

    deposit.Deposit GetDeposit (1: DepositID id)
        throws (
            1: fistful.DepositNotFound ex1
        )
}
