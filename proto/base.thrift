/**
 * Отметка во времени согласно RFC 3339.
 *
 * Строка должна содержать дату и время в UTC в следующем формате:
 * `2016-03-22T06:12:27Z`.
 */

 namespace java com.rbkmoney.fistful.base

typedef string Timestamp

/** Идентификатор объекта */
typedef string ID

/** Идентификатор некоторого события */
typedef i64 EventID

/** ISO 4217 */
typedef string CurrencySymbolicCode

/** Сумма в минимальных денежных единицах. */
typedef i64 Amount

/**
 * Идентификатор валюты
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L912
 */
struct CurrencyRef { 1: required CurrencySymbolicCode symbolic_code }

/**
 * Объём денежных средств
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L70
 */
struct Cash {
    1: required Amount amount
    2: required CurrencyRef currency
}

typedef string Token

/**
 * Банковская карта
 *
 * Сделано по мотивам https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L1323
 * От оргигинала отличается меньшим количеством полей и меньшими ограничениями на имеющиеся поля
 */
struct BankCard {
    1: required Token token
    2: optional BankCardPaymentSystem payment_system
    3: optional string bin
    4: optional string masked_pan
    /*
    Поля 5-8 зарезервированы для совместимости с BankCard из damsel
    5: optional BankCardTokenProvider token_provider
    6: optional Residence issuer_country
    7: optional string bank_name
    8: optional map<string, msgpack.Value> metadata
    */
}

/**
 * Платежные системы
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L1282
 */
enum BankCardPaymentSystem {
    visa
    mastercard
    visaelectron
    maestro
    forbrugsforeningen
    dankort
    amex
    dinersclub
    discover
    unionpay
    jcb
    nspkmir
}
