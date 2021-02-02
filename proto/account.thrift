/**
 * Счета
 */

namespace java   com.rbkmoney.fistful.account
namespace erlang account

include "base.thrift"
include "fistful.thrift"
include "identity.thrift"

/// Domain

typedef fistful.AccountID AccountID
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

struct AccountBalance {
    1: required AccountID id
    2: required base.CurrencyRef currency
    3: required base.Amount expected_min
    4: required base.Amount current
    5: required base.Amount expected_max
}
