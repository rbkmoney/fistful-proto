/**
 * Провайдеры
 */

namespace java   com.rbkmoney.fistful.provider
namespace erlang provider

include "base.thrift"
include "fistful.thrift"

/// Domain

typedef base.ID ProviderID

struct Provider {
    1: required ProviderID id
    2: required string name
    3: required list<string> residences
}

///

// Временное решение, которое будет удалено после выполнения https://rbkmoney.atlassian.net/browse/FF-235

service Management {
    Provider GetProvider (
        1: ProviderID id
    )
        throws (1: fistful.ProviderNotFound ex1)

    list<Provider> ListProviders ()
}
