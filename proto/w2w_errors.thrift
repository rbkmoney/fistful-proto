/**
 * Ошибки переводов
 */

namespace java   com.rbkmoney.fistful.w2w_errors
namespace erlang w2w_errors

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
  * W2WFailure{
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

union W2WFailure {
    1: LimitExceeded  account_limit_exceeded
}

union LimitExceeded {
  1: GeneralFailure unknown
  2: GeneralFailure amount
}

struct GeneralFailure {}
