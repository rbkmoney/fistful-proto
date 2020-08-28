/**
 * Ошибки переводов
 */

namespace java   com.rbkmoney.fistful.p2p_errors
namespace erlang p2p_errors

/**
  *
  *
  * # Статическое представление ошибок. (динамическое представление — base.Failure)
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
  * P2PFailure{
  *     account_limit_exceeded = LimitExceeded{
  *         amount = GeneralFailure{}
  *     }
  * }
  * ```
  *
  *
  * ### Текстовое представление (нужно только если есть желание представлять ошибки в виде текста)
  *
  * `account_limit_exceeded:amount:`
  *
  *
  * ### Динамически типизированное представление
  *
  * ```
  * base.Failure{
  *     code = "account_limit_exceeded",
  *     sub = base.SubFailure{
  *         code = "amount"
  *     }
  * }
  * ```
  *
  */

union P2PFailure {
    1: AuthorizationFailure authorization_failed
    2: GeneralFailure no_route_found
}

union AuthorizationFailure {
    1: GeneralFailure unknown
    2: GeneralFailure deadline_reached
}

struct GeneralFailure {}
