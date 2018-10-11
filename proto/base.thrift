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
