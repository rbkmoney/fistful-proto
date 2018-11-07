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
typedef base.ID AccounterAccountID

struct Account {
    3: required AccountID id
    1: required identity.IdentityID identity
    2: required base.CurrencyRef currency
    4: required AccounterAccountID accounter_account_id
}

/// Wallet events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

