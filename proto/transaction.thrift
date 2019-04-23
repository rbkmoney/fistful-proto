/**
 * Трансферы
 */

namespace java   com.rbkmoney.fistful.transaction
namespace erlang transaction

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"

include "t_withdrawal.thrift"

typedef fistful.SessionID                   SessionID
typedef fistful.TransferID                  TransferID
typedef base.Cash                           Cash
typedef cashflow.FinalCashFlow              FinalCashFlow
typedef t_withdrawal.SessionDataWithdrawal  SessionDataWithdrawal

/// Domain

struct Transaction {
    2: required TransferID      id
    3: required Cash            body
    4: required SessionData     session_data
    5: required FinalCashFlow   final_cash_flow
}

union SessionData {
    1: SessionDataEmpty         empty
    2: SessionDataWithdrawal    withdrawal
}

struct SessionDataEmpty {}

union TransactionStatus {
    1: TransactionPending       pending
    2: TransactionSucceeded     succeeded
    3: TransactionFailed        failed
}

struct TransactionPending {}
struct TransactionSucceeded {}
struct TransactionFailed {
    1: required Failure         failure
}

struct Failure {
    // TODO
}

struct PostingsTransfer {
    1: required FinalCashFlow   cashflow
}

union PostingsTransferStatus {
    1: PostingsTransferStatusCreated   created
    2: PostingsTransferStatusPrepared  prepared
    3: PostingsTransferStatusCommitted committed
    4: PostingsTransferStatusCancelled cancelled
}

struct PostingsTransferStatusCreated {}
struct PostingsTransferStatusPrepared {}
struct PostingsTransferStatusCommitted {}
struct PostingsTransferStatusCancelled {}

/// Transaction events

union TransactionChange {
    1: TransactionCreated       created
    2: TransactionStatus        status_changed
    3: PostingsTransferChange   postings_transfer_changed
    4: SessionChange            session_changed
}

struct TransactionCreated {
    1: required Transaction     transaction
}

union PostingsTransferChange {
    1: PostingsTransferCreated   created
    2: PostingsTransferStatus    status_changed
}

struct PostingsTransferCreated {
    1: required PostingsTransfer posting_transfer
}

struct SessionChange {
    1: required SessionID id
    2: required SessionChangePayload payload
}

union SessionChangePayload {
    1: SessionStarted   started
    2: SessionFinished  finished
}

struct SessionStarted {}
struct SessionFinished {}
