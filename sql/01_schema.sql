
-- UTS CODING AKUNTANSI - SOAL 1
-- Struktur database jurnal akuntansi

CREATE TABLE public.chart_of_accounts (
    account_code VARCHAR(20) PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    normal_balance VARCHAR(6) NOT NULL
        CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    report_classification VARCHAR(20) NOT NULL
        CHECK (
            report_classification IN (
                'ASSET',
                'LIABILITY',
                'EQUITY',
                'REVENUE',
                'EXPENSE'
            )
        )
);

CREATE TABLE public.journal_headers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    reference_no VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    posting_status VARCHAR(10) NOT NULL DEFAULT 'DRAFT'
        CHECK (posting_status IN ('DRAFT', 'POSTED'))
);

CREATE TABLE public.journal_lines (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    header_id BIGINT NOT NULL,
    account_code VARCHAR(20) NOT NULL,
    debit NUMERIC(15, 2) NOT NULL DEFAULT 0,
    credit NUMERIC(15, 2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_lines_header
        FOREIGN KEY (header_id)
        REFERENCES public.journal_headers(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_lines_account
        FOREIGN KEY (account_code)
        REFERENCES public.chart_of_accounts(account_code)
        ON DELETE RESTRICT,

    CONSTRAINT chk_debit_nonnegative
        CHECK (debit >= 0),

    CONSTRAINT chk_credit_nonnegative
        CHECK (credit >= 0),

    CONSTRAINT chk_line_not_zero
        CHECK (debit > 0 OR credit > 0),

    CONSTRAINT chk_one_side_per_line
        CHECK (debit = 0 OR credit = 0)
);