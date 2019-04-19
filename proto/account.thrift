/**
 * Счета
 */

namespace java   com.rbkmoney.fistful.account
namespace erlang account

include "base.thrift"
include "fistful.thrift"
include "identity.thrift"

/// Domain

typedef base.ID AccountID
typedef i64 AccounterAccountID
typedef base.CurrencySymbolicCode CurrencySymbolicCode

struct AccountParams {
    1: required fistful.IdentityID identity_id
    2: required CurrencySymbolicCode symbolic_code
}

struct Account {
    3: required AccountID id
    1: required identity.IdentityID identity
    2: required base.CurrencyRef currency
    4: required AccounterAccountID accounter_account_id
}
