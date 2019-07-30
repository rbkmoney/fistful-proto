/**
 * Ошибки выводов
 */

namespace java   com.rbkmoney.fistful.withdrawal_errors
namespace erlang wthd_errors

union WithdrawalFailure {
    1: GeneralFailure wallet_limit_exceeded
    2: GeneralFailure no_route_found
    3: GeneralFailure quote_expired
}

struct GeneralFailure {}
