include "base.thrift"

namespace java com.rbkmoney.fistful.webhooker
namespace erlang webhooker

typedef base.ID PartyID
typedef base.ID ShopID
typedef string Url
typedef string Key
typedef i64 WebhookID
exception WebhookNotFound {}

struct Webhook {
    1: required WebhookID id
    2: required PartyID party_id
    3: optional ShopID shop_id
    4: required EventFilter event_filter
    5: required Url url
    6: required Key pub_key
    7: required bool enabled
}

struct WebhookParams {
    1: required PartyID party_id
    2: optional ShopID shop_id
    3: required EventFilter event_filter
    4: required Url url
}

struct EventFilter {
    1: required set<EventType> types
}

union EventType {
    1: WithdrawalEventType withdrawal

    2: DepositeEventType deposit

    3: SourceEventType source

    4: WalletEventType wallet
}

union WithdrawalEventType {
    1: WithdrawalStarted started
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed failed
}

union DepositeEventType {
    1: DepositeStarted started
    2: DepositeSucceeded succeeded
    3: DepositeFailed failed
}

union SourceEventType {
    1: SourceCreated created
    2: AccountChanged account_changed
    3: StatusChanged status_changed
}

union WalletEventType {
    1: WalletCreated created
    2: AccountChanged account_changed
}

struct WithdrawalStarted {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {}

struct DepositeStarted {}
struct DepositeSucceeded {}
struct DepositeFailed {}

struct SourceCreated {}
struct AccountChanged {}
struct WalletCreated {}
struct StatusChanged {}

service WebhookManager {
    list<Webhook> GetList(1: PartyID party_id)
    Webhook Get(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
    Webhook Create(1: WebhookParams webhook_params)
    void Delete(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
}