/**
 * Очередь событий
 */

namespace java   com.rbkmoney.fistful.eventsink
namespace erlang evsink

typedef i64 EventID
typedef i32 SequenceID

struct EventRange {
    1: optional EventID after
    2: required i32 limit
}

exception NoLastEvent {}
