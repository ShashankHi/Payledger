package com.payledger.payledger_be.constants;

public class ErrorCodes {

    private ErrorCodes(){}

    //Auth and Status
    public static final String INVALID_CREDENTIALS = "INVALID_CREDENTIALS";
    public static final String EMAIL_ALREADY_EXISTS = "EMAIL_ALREADY_EXISTS";
    public static final String ACCOUNT_PENDING_APPROVAL = "ACCOUNT_PENDING_APPROVAL";
    public static final String ACCOUNT_REJECTED = "ACCOUNT_REJECTED";
    public static final String ACCOUNT_SUSPENDED = "ACCOUNT_SUSPENDED";
    public static final String ACCESS_DENIED = "ACCESS_DENIED";
    public static final String INVALID_TOKEN = "INVALID_TOKEN";

    //Money
    public static final String INSUFFICIENT_FUNDS = "INSUFFICIENT_FUNDS";
    public static final String LIMIT_EXCEEDED = "LIMIT_EXCEEDED";
    public static final String ACCOUNT_FROZEN = "ACCOUNT_FROZEN";
    public static final String SAME_ACCOUNT_TRANSFER = "SAME_ACCOUNT_TRANSFER";
    public static final String INVALID_AMOUNT = "INVALID_AMOUNT";

    //Idempotency
    public static final String DUPLICATE_REQUEST = "DUPLICATE_REQUEST";
    public static final String IDEMPOTENCY_KEY_REUSED = "IDEMPOTENCY_KEY_REUSED";
    public static final String IDEMPOTENCY_KEY_MISSING = "IDEMPOTENCY_KEY_MISSING";

    //State and General
    public static final String INVALID_TRANSACTION_STATE = "INVALID_TRANSACTION_STATE";
    public static final String INVALID_USER_STATE = "INVALID_USER_STATE";
    public static final String REASON_REQUIRED = "REASON_REQUIRED";
    public static final String RESOURCE_NOT_FOUND = "RESOURCE_NOT_FOUND";
    public static final String VALIDATION_FAILED = "VALIDATION_FAILED";
    public static final String INTERNAL_ERROR = "INTERNAL_ERROR";

}
