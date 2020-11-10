/**
 * Структуры для сериализации платежного токена
 */

namespace java com.rbkmoney.fistful.payment_resource_token
namespace erlang prt

include "base.thrift"

/**
 *  Платежный токен, который передается плательщику. Платежный токен содержит
 *  чувствительные данные, которые сериализуются в thrift-binary и шифруются перед отправкой клиенту.
 *  Платежный токен может иметь срок действия, по истечении которого становится недействительным.
 */
struct PaymentResourceToken {
    1: required PaymentResourcePayload payload
    2: optional base.Timestamp valid_until
}

/**
 *  Данные платежного ресурса
 */
union PaymentResourcePayload {
    1: BankCardPayload bank_card_payload
}

struct BankCardPayload {
    1: required base.BankCard bank_card
}
