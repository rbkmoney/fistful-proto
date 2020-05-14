/**
 * Процесс движения денег между счетами
 */

namespace java   com.rbkmoney.fistful.transfer
namespace erlang transfer

include "base.thrift"
include "cashflow.thrift"

struct Transfer {
    1: required cashflow.FinalCashFlow cashflow
    2: optional base.ID id
}

union Status {
    1: Created   created
    2: Prepared  prepared
    3: Committed committed
    4: Cancelled cancelled
}

struct Created {}
struct Prepared {}
struct Committed {}
struct Cancelled {}

union Change {
    1: CreatedChange  created
    2: StatusChange   status_changed
    3: ClockChange    clock_updated
}

struct CreatedChange {
    1: required Transfer transfer
}

struct StatusChange {
    1: required Status status
}

struct ClockChange {
    1: required Clock clock
}

union Clock {
    1: LatestClock latest
    2: VectorClock vector
}

struct LatestClock {}

struct VectorClock {
    1: required binary state
}
