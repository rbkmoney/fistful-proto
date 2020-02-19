/**
 * Проверка лимитов
 */

namespace java   com.rbkmoney.fistful.limit_check
namespace erlang lim_check

include "base.thrift"

union Details {
    1: WalletDetails wallet_sender
    2: WalletDetails wallet_receiver
}

union WalletDetails {
    1: WalletOk ok
    2: WalletFailed failed
}

struct WalletFailed {
    1: required base.CashRange expected
    2: required base.Cash balance
}

struct WalletOk {}
