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

struct EventRange {
    1: optional EventID after
    2: required i32     limit
}

/** ISO 4217 */
typedef string CurrencySymbolicCode

/** Сумма в минимальных денежных единицах. */
typedef i64 Amount

/** Внешний идентификатор (идентификатор в системе клиента) для сущностей системы. */
typedef ID ExternalID

typedef i64 DataRevision
typedef i64 PartyRevision

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

struct CashRange {
    1: required CashBound upper
    2: required CashBound lower
}

union CashBound {
    1: Cash inclusive
    2: Cash exclusive
}

typedef string Token

/** Отображение из строки в строку */
typedef map<string, string> StringMap

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
 * Криптокошелёк
 */
struct CryptoWallet {
    1: required string id
    3: optional CryptoData data
    /** Legacy */
    2: required CryptoCurrency currency
}

/**
 * Криптовалюта
 */
enum CryptoCurrency {
    bitcoin
    litecoin
    bitcoin_cash
    ripple
    ethereum
    zcash
}

union CryptoData {
    1: CryptoDataBitcoin bitcoin
    2: CryptoDataLitecoin litecoin
    3: CryptoDataBitcoinCash bitcoin_cash
    4: CryptoDataRipple ripple
    5: CryptoDataEthereum ethereum
    6: CryptoDataZcash zcash
}

struct CryptoDataBitcoin {}
struct CryptoDataLitecoin {}
struct CryptoDataBitcoinCash {}
struct CryptoDataRipple {
    1: required string tag
}
struct CryptoDataEthereum {}
struct CryptoDataZcash {}

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

/**
 * Ошибки
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L31
 */
struct Failure {
    1: required FailureCode     code;

    2: optional FailureReason   reason;
    3: optional SubFailure      sub;
}

typedef string FailureCode;
typedef string FailureReason; // причина возникшей ошибки и пояснение откуда она взялась

// возможность делать коды ошибок иерархическими
struct SubFailure {
    1: required FailureCode  code;
    2: optional SubFailure   sub;
}

/**
 * Данные транзакции
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L77
 */

struct TransactionInfo {
    1: required ID  id
    2: optional Timestamp timestamp
    3: required StringMap extra
    4: optional AdditionalTransactionInfo additional_info
}

struct AdditionalTransactionInfo {
    1: optional string rrn // Retrieval Reference Number
    2: optional string approval_code // Authorization Approval Code
    3: optional string acs_url // Issuer Access Control Server (ACS)
    4: optional string pareq // Payer Authentication Request (PAReq)
    5: optional string md // Merchant Data
    6: optional string term_url // Upon success term_url callback is called with following form encoded params
    7: optional string pares // Payer Authentication Response (PARes)
    8: optional string eci // Electronic Commerce Indicator
    9: optional string cavv // Cardholder Authentication Verification Value
    10: optional string xid // 3D Secure transaction identifier
    11: optional string cavv_algorithm // Indicates algorithm used to generate CAVV
    12: optional ThreeDsVerification three_ds_verification
}

/**
* Issuer Authentication Results Values
**/
enum ThreeDsVerification {
    authentication_successful // Y
    attempts_processing_performed // A
    authentication_failed // N
    authentication_could_not_be_performed // U
}
