/**
 * Интерфейс сервиса статистики и связанные с ним определения предметной области, основанные на моделях домена.
 */

include "base.thrift"
include "fistful.thrift"

namespace java com.rbkmoney.damsel.fistful_stat
namespace erlang fistfulstat

typedef fistful.WalletID WalletID
typedef fistful.WithdrawalID WithdrawalID
typedef fistful.DestinationID DestinationID
typedef fistful.IdentityID IdentityID
typedef base.CurrencySymbolicCode CurrencySymbolicCode

/**
* Информация о кошельке
*/
struct StatWallet {
    1 : required WalletID             id
    2 : required IdentityID           identity_id
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
    6:  required Destination          destination_resource
    7:  required base.Amount          amount
    8:  required base.Amount          fee
    9:  required CurrencySymbolicCode currency_symbolic_code
    10: required WithdrawalStatus     status
}

struct Destination {
    1: required string   name
    2: required Resource resource
}

union Resource {
    1: base.BankCard    bank_card
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

}

