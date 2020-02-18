/**
 * Статусы возврата ввода
 */

namespace java   com.rbkmoney.fistful.w2w_transfer.revert.status
namespace erlang w2w_rev_status

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
