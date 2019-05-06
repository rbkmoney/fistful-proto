/**
 * Выплаты
 */

namespace java   com.rbkmoney.fistful.t_withdrawal
namespace erlang t_withdrawal

include "base.thrift"
include "fistful.thrift"
include "identity.thrift"

typedef fistful.SessionID     SessionID
typedef fistful.ProviderID    ProviderID
typedef fistful.WalletID      WalletID
typedef fistful.DestinationID DestinationID

typedef identity.Identity     Identity
typedef base.Cash             Cash

/// Domain

struct WithdrawalParams {
    1: required WalletID       wallet_id
    2: required DestinationID  destination_id
}

struct SessionDataWithdrawal {
    1: required SessionWithdrawalParams   params
}

struct SessionWithdrawalParams {
    1: required SessionID           id
    2: required Cash                cash
    3: required Identity            sender
    4: required Identity            receiver
    5: required DestinationID       destination_id
    6: required ProviderID          provider_id
}

struct RouteWithdrawal {
    1: required ProviderID  id
}
