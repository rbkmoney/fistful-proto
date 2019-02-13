/**
 * Полностью вычисленный граф финансовых потоков с проводками всех участников.
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L1518
 */

namespace java   com.rbkmoney.fistful.cashflow
namespace erlang cashflow

include "base.thrift"
include "fistful.thrift"

struct FinalCashFlow {
    1: required list<FinalCashFlowPosting> postings
}

struct FinalCashFlowPosting {
    1: required FinalCashFlowAccount source
    2: required FinalCashFlowAccount destination
    3: required base.Cash volume
    4: optional string details
}

struct FinalCashFlowAccount {
    1: required CashFlowAccount account_type
    2: required fistful.AccountID account_id
}

union CashFlowAccount {
    1: MerchantCashFlowAccount merchant
    2: ProviderCashFlowAccount provider
    3: SystemCashFlowAccount system
    4: ExternalCashFlowAccount external
    5: WalletCashFlowAccount wallet
}

enum MerchantCashFlowAccount {
    settlement
    guarantee
    payout
}

enum ProviderCashFlowAccount {
    settlement
}

enum SystemCashFlowAccount {
    settlement
    subagent
}

enum ExternalCashFlowAccount {
    income
    outcome
}

enum WalletCashFlowAccount {
    sender_source
    sender_settlement
    receiver_settlement
    receiver_destination
}
