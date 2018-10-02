/**
 * Определение непрозрачного контекста объектов.
 */

namespace java com.rbkmoney.identity.ctx
namespace erlang identity_ctx

include "msgpack.thrift"

/**
 * Пространство имён, отделяющее конексты одного сервиса.
 *
 * Например, `com.rbkmoney.capi`.
 */
typedef string                  Namespace

/**
 * Структурированное значение контекста в формате msgpack.
 *
 * Например, `{"metadata": {"order": "N1488"}}`.
 */
typedef msgpack.Value           Context

typedef map<Namespace, Context> ContextSet
