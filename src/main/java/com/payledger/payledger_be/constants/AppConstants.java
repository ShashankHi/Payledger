package com.payledger.payledger_be.constants;

public class AppConstants {

    private AppConstants(){}

    public static final String DEFAULT_CURRENCY = "INR";

    //MUST MATCH THE ROWS SEEDED IN V5__SEED_SYSTEM_ACCOUNTS.SQL
    public static final String EXTERNAL_FUNDING_ACCOUNT_NUMBER = "SYS-EXTERNAL-FUNDING";
    public static final String FEE_COLLECTION_ACCOUNT_NUMBER = "SYS-FEE-COLLECTION";

    public static final String ACCOUNT_NUMBER_PREFIX = "PL";
    public static final String IDEMPOTENCY_HEADER = "Idempotency-Key";
    public static final long IDEMPOTENCY_TTL_HOURS = 24;

    public static final int MONEY_SCALE = 4;

    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int MAX_PAGE_SIZE = 100;
}
