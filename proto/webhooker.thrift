include "base.thrift"

namespace java com.rbkmoney.fistful.webhooker
namespace erlang webhooker

typedef base.ID PartyID
typedef string Url
typedef string Key
typedef i64 WebhookID
exception WebhookNotFound {}

struct Webhook {
    1: required WebhookID id
    2: required PartyID party_id
    3: required EventFilter event_filter
    4: required Url url
    5: required Key pub_key
    6: required bool enabled
}

struct WebhookParams {
    1: required PartyID party_id
    2: required EventFilter event_filter
    3: required Url url
}

union EventFilter {
    1: WalletEventFilter wallet
}

struct WalletEventFilter {
    1: required set<WalletEventType> types
}

union WalletEventType {
    1: WalletWithdrawalEventType withdrawal
}

union WalletWithdrawalEventType {
    1: WalletWithdrawalStarted started
    2: WalletWithdrawalSucceeded succeeded
    3: WalletWithdrawalFailed failed
}

struct WalletWithdrawalStarted {}
struct WalletWithdrawalSucceeded {}
struct WalletWithdrawalFailed {}

service WebhookManager {
    list<Webhook> GetList(1: PartyID party_id)
    Webhook Get(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
    Webhook Create(1: WebhookParams webhook_params)
    void Delete(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
}