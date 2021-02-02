/**
 * Структуры для сериализации токена платёжного ресурса
 */

namespace java com.rbkmoney.fistful.resource_token
namespace erlang rst

include "base.thrift"

/**
 *  Токен пользовательского платёжного ресурса. Токен содержит чувствительные данные, которые сериализуются
 *  в thrift-binary и шифруются перед отправкой пользователю.  Токен может иметь срок действия, по истечении которого
 *  становится недействительным.
 */
struct ResourceToken {
    1: required ResourcePayload payload
    2: optional base.Timestamp valid_until
}

/**
 *  Данные платёжного ресурса
 */
union ResourcePayload {
    1: BankCardPayload bank_card_payload
}

struct BankCardPayload {
    1: required base.BankCard bank_card
}
