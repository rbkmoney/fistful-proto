/**
 * Интерфейс сервиса статистики и связанные с ним определения предметной области, основанные на моделях домена.
 */

include "base.thrift"
include "fistful.thrift"

namespace java com.rbkmoney.fistful.fistful_stat
namespace erlang fistfulstat

typedef fistful.WalletID WalletID
typedef fistful.WithdrawalID WithdrawalID
typedef fistful.DepositID DepositID
typedef fistful.DestinationID DestinationID
typedef fistful.SourceID SourceID
typedef fistful.IdentityID IdentityID
typedef base.CurrencySymbolicCode CurrencySymbolicCode
typedef fistful.ID ClassID
typedef fistful.ID LevelID
typedef fistful.ID IdentityChallengeID
typedef fistful.ID IdentityProviderID

/**
* Информация о кошельке
*/
struct StatWallet {
    1 : required WalletID             id
    2 : required IdentityID           identity_id
    5:  optional base.Timestamp       created_at
    3 : optional string               name
    4 : optional CurrencySymbolicCode currency_symbolic_code
}

/**
* Информация о выводе
*/
struct StatWithdrawal {
    1:  required WithdrawalID         id
    2:  required base.Timestamp       created_at
    3:  required IdentityID           identity_id
    4:  required WalletID             source_id
    5:  required DestinationID        destination_id
    6:  optional base.ExternalID      external_id
    7:  required base.Amount          amount
    8:  required base.Amount          fee
    9:  required CurrencySymbolicCode currency_symbolic_code
    10: required WithdrawalStatus     status
}

union WithdrawalStatus {
    1: WithdrawalPending pending
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed failed
}

struct WithdrawalPending {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {
    1: required Failure failure
}

struct Failure {
    // TODO
}

/**
* Информация о пополнении
*/
struct StatDeposit {
    1:  required DepositID            id
    2:  required base.Timestamp       created_at
    3:  required IdentityID           identity_id
    4:  required WalletID             destination_id
    5:  required SourceID             source_id
    7:  required base.Amount          amount
    8:  required base.Amount          fee
    9:  required CurrencySymbolicCode currency_symbolic_code
    10: required DepositStatus        status
}

union DepositStatus {
    1: DepositPending pending
    2: DepositSucceeded succeeded
    3: DepositFailed failed
}

struct DepositPending {}
struct DepositSucceeded {}
struct DepositFailed {
    1: required Failure failure
}

/**
* Информация о приёмнике средств
*/

struct StatDestination {
    1: required DestinationID id
    2: required string name
    3: optional base.Timestamp created_at
    4: optional bool is_blocked
    5: required IdentityID identity
    6: required CurrencySymbolicCode currency_symbolic_code
    7: required DestinationResource resource
    8: optional base.ExternalID external_id
    9: optional DestinationStatus status
}

union DestinationResource {
    1: base.BankCard bank_card
    2: base.CryptoWallet crypto_wallet
}

union DestinationStatus {
    1: Unauthorized unauthorized
    2: Authorized authorized
}

struct Unauthorized {}
struct Authorized {}

/**
* Информация о личности
*/
struct StatIdentity {
    1: required IdentityID id
    2: required string name
    3: optional base.Timestamp created_at
    4: required IdentityProviderID provider
    5: required ClassID identity_class
    6: optional LevelID identity_level
    7: optional IdentityChallengeID effective_challenge
    8: optional bool is_blocked
    9: optional base.ExternalID external_id
}

/**
* Данные запроса к сервису. Формат и функциональность запроса зависят от DSL.
 * DSL содержит условия выборки, а также id мерчанта, по которому производится выборка.
 * continuation_token - токен, который передается в случае обращения за следующим блоком данных, соответствующих dsl
*/
struct StatRequest {
    1: required string dsl
    2: optional string continuation_token
}

/**
* Данные ответа сервиса.
* data - данные, тип зависит от целевой функции.
* total_count - ожидаемое общее количество данных (т.е. размер всех данных результата, без ограничений по количеству)
* continuation_token - токен, сигнализирующий о том, что в ответе передана только часть данных, для получения следующей части
* нужно повторно обратиться к сервису, указав тот-же набор условий и continuation_token. Если токена нет, получена последняя часть данных.
*/
struct StatResponse {
    1: required StatResponseData data
    2: optional i32 total_count
    3: optional string continuation_token
}

/**
* Возможные варианты возвращаемых данных
*/
union StatResponseData {
    1: list<StatWallet> wallets
    2: list<StatWithdrawal> withdrawals
    3: list<StatDeposit> deposits
    4: list<StatDestination> destinations
    5: list<StatIdentity> identities
}

/**
* Ошибка обработки переданного токена, при получении такой ошибки клиент должен заново запросить все данные, соответсвующие dsl запросу
*/
exception BadToken {
    1: string reason
}

/**
 * Исключение, сигнализирующее о непригодных с точки зрения бизнес-логики входных данных
 */
exception InvalidRequest {
    /** Список пригодных для восприятия человеком ошибок во входных данных */
    1: required list<string> errors
}

service FistfulStatistics {

    /**
     *  Возвращает набор данных о кошельках
     */
    StatResponse GetWallets(1: StatRequest req) throws (1: InvalidRequest ex1, 3: BadToken ex3)

    /**
     * Возвращает набор данных о выводах
     */
    StatResponse GetWithdrawals(1: StatRequest req) throws (1: InvalidRequest ex1, 3: BadToken ex3)

    /**
     * Возвращает набор данных о пополнениях
     */
    StatResponse GetDeposits(1: StatRequest req) throws (1: InvalidRequest ex1, 3: BadToken ex3)

    /**
     * Возвращает набор данных о приёмниках средств
     */
    StatResponse GetDestinations(1: StatRequest req) throws (1: InvalidRequest ex1, 2: BadToken ex3)

    /**
     * Возвращает набор данных о личностях
     */
    StatResponse GetIdentities(1: StatRequest req) throws (1: InvalidRequest ex1, 2: BadToken ex3)

}
