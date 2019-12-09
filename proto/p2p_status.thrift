/**
 * Статусы перевода
 */

namespace java   com.rbkmoney.fistful.p2p.status
namespace erlang p2p_status

include "base.thrift"
typedef base.Failure Failure

union Status {
    1: Pending pending
    2: Succeeded succeeded
    3: Failed failed
}

struct Pending {}
struct Succeeded {}
struct Failed {
    1: required Failure failure
}
