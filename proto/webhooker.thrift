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

struct EventFilter {
    1: required set<EventType> types
}

union EventType {
    1: WithdrawalEventType withdrawal
}

union WithdrawalEventType {
    1: WithdrawalStarted started
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed failed
}

struct WithdrawalStarted {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {}

service WebhookManager {
    list<Webhook> GetList(1: PartyID party_id)
    Webhook Get(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
    Webhook Create(1: WebhookParams webhook_params)
    void Delete(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
}