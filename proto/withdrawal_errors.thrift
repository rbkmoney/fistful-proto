/**
 * Ошибки выводов
 */

namespace java   com.rbkmoney.fistful.withdrawal_errors
namespace erlang wthd_errors

/**
  *
  *
  * # Статическое представление ошибок. (динамическое представление — domain.Failure)
  *
  * При переводе из статического в динамические формат представления следующий.
  * В поле code пишется строковое представления имени варианта в union,
  * далее если это не структура, а юнион, то в поле sub пишется SubFailure,
  * который рекурсивно обрабатывается по аналогичном правилам.
  *
  * Текстовое представление аналогично через имена вариантов в юнион с разделителем в виде двоеточия.
  *
  *
  * ## Например
  *
  *
  * ### Статически типизированное представление
  *
  * ```
  * PaymentFailure{
  *     authorization_failed = AuthorizationFailure{
  *         payment_tool_rejected = PaymentToolReject{
  *             bank_card_rejected = BankCardReject{
  *                 cvv_invalid = GeneralFailure{}
  *             }
  *         }
  *     }
  * }
  * ```
  *
  *
  * ### Текстовое представление (нужно только если есть желание представлять ошибки в виде текста)
  *
  * `authorization_failed:payment_tool_rejected:bank_card_rejected:cvv_invalid`
  *
  *
  * ### Динамически типизированное представление
  *
  * ```
  * domain.Failure{
  *     code = "authorization_failed",
  *     reason = "sngb error '87' — 'Invalid CVV'",
  *     sub = domain.SubFailure{
  *         code = "payment_tool_rejected",
  *         sub = domain.SubFailure{
  *             code = "bank_card_rejected",
  *             sub = domain.SubFailure{
  *                 code = "cvv_invalid"
  *             }
  *         }
  *     }
  * }
  * ```
  *
  */

union WithdrawalFailure {
    1: LimitExceeded  account_limit_exceeded
    2: LimitExceeded  provider_limit_exceeded
    3: GeneralFailure no_route_found
    4: GeneralFailure quote_expired
}

union LimitExceeded {
  1: GeneralFailure unknown
  2: GeneralFailure amount
  3: GeneralFailure number
}

struct GeneralFailure {}
