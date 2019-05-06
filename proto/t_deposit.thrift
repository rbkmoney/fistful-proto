/**
 * Трансферы
 */

namespace java   com.rbkmoney.fistful.t_deposit
namespace erlang t_deposit

include "base.thrift"
include "fistful.thrift"

typedef fistful.WalletID      WalletID
typedef fistful.SourceID      SourceID

/// Domain

struct DepositParams {
    1: required WalletID       wallet_id
    2: required SourceID       source_id
}

struct RevertDepositParams {
    1: optional string         reason
}
