namespace erlang ff_tmbhv
namespace java com.rbkmoney.fistful.timeout_behaviour
include "base.thrift"

typedef base.Opaque Callback

union TimeoutBehaviour {
    /** Неуспешное завершение взаимодействия с пояснением возникшей проблемы. */
    1: base.OperationFailure operation_failure
    /** Вызов прокси для обработки события истечения таймаута. */
    2: Callback callback
}
