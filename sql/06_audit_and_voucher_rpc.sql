-- 06_audit_and_voucher_rpc.sql

-- Tambahkan kolom audit trail pada header jurnal.
ALTER TABLE public.journal_headers
    ADD COLUMN IF NOT EXISTS created_by TEXT
        NOT NULL DEFAULT 'local-demo',
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ
        NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS hash_checksum TEXT;

-- Fungsi untuk menyimpan voucher secara atomik.
CREATE OR REPLACE FUNCTION public.create_cash_voucher(
    p_reference_no TEXT,
    p_transaction_date DATE,
    p_description TEXT,
    p_lines JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
    v_header_id BIGINT;
    v_line JSONB;
    v_account_code VARCHAR(20);
    v_debit NUMERIC(15, 2);
    v_credit NUMERIC(15, 2);
    v_total_debit NUMERIC(15, 2) := 0;
    v_total_credit NUMERIC(15, 2) := 0;
    v_line_count INTEGER;
    v_checksum TEXT;
BEGIN
    -- Validasi informasi utama.
    IF NULLIF(TRIM(p_reference_no), '') IS NULL THEN
        RAISE EXCEPTION 'Nomor voucher wajib diisi.';
    END IF;

    IF NULLIF(TRIM(p_description), '') IS NULL THEN
        RAISE EXCEPTION 'Keterangan transaksi wajib diisi.';
    END IF;

    IF p_transaction_date IS NULL THEN
        RAISE EXCEPTION 'Tanggal transaksi wajib diisi.';
    END IF;

    IF p_lines IS NULL OR jsonb_typeof(p_lines) <> 'array' THEN
        RAISE EXCEPTION 'Rincian jurnal harus berbentuk array.';
    END IF;

    v_line_count := jsonb_array_length(p_lines);

    IF v_line_count < 2 THEN
        RAISE EXCEPTION 'Jurnal harus memiliki minimal dua baris.';
    END IF;

    -- Validasi semua baris dan hitung total.
    FOR v_line IN
        SELECT value FROM jsonb_array_elements(p_lines)
    LOOP
        v_account_code :=
            NULLIF(v_line->>'account_code', '')::VARCHAR(20);

        v_debit := COALESCE(
            NULLIF(v_line->>'debit', '')::NUMERIC,
            0
        );

        v_credit := COALESCE(
            NULLIF(v_line->>'credit', '')::NUMERIC,
            0
        );

        IF v_account_code IS NULL THEN
            RAISE EXCEPTION 'Kode akun wajib diisi.';
        END IF;

        IF v_debit < 0 OR v_credit < 0 THEN
            RAISE EXCEPTION 'Debit dan kredit tidak boleh negatif.';
        END IF;

        IF v_debit = 0 AND v_credit = 0 THEN
            RAISE EXCEPTION 'Setiap baris harus memiliki nilai debit atau kredit.';
        END IF;

        IF v_debit > 0 AND v_credit > 0 THEN
            RAISE EXCEPTION 'Satu baris tidak boleh berisi debit dan kredit sekaligus.';
        END IF;

        v_total_debit := v_total_debit + v_debit;
        v_total_credit := v_total_credit + v_credit;
    END LOOP;

    IF v_total_debit <= 0 OR v_total_debit <> v_total_credit THEN
        RAISE EXCEPTION
            'Jurnal tidak seimbang. Debit: %, kredit: %.',
            v_total_debit, v_total_credit;
    END IF;

    -- Buat header sebagai DRAFT terlebih dahulu.
    INSERT INTO public.journal_headers (
        transaction_date,
        reference_no,
        description,
        posting_status
    )
    VALUES (
        p_transaction_date,
        TRIM(p_reference_no),
        TRIM(p_description),
        'DRAFT'
    )
    RETURNING id INTO v_header_id;

    -- Simpan seluruh rincian jurnal.
    FOR v_line IN
        SELECT value FROM jsonb_array_elements(p_lines)
    LOOP
        INSERT INTO public.journal_lines (
            header_id,
            account_code,
            debit,
            credit
        )
        VALUES (
            v_header_id,
            (v_line->>'account_code')::VARCHAR(20),
            COALESCE(NULLIF(v_line->>'debit', '')::NUMERIC, 0),
            COALESCE(NULLIF(v_line->>'credit', '')::NUMERIC, 0)
        );
    END LOOP;

    -- Simpan checksum untuk membantu mendeteksi perubahan data.
    v_checksum := md5(
        v_header_id::TEXT || '|' ||
        TRIM(p_reference_no) || '|' ||
        p_transaction_date::TEXT || '|' ||
        TRIM(p_description) || '|' ||
        p_lines::TEXT
    );

    UPDATE public.journal_headers
    SET created_by = 'local-demo',
        created_at = NOW(),
        hash_checksum = v_checksum,
        posting_status = 'POSTED'
    WHERE id = v_header_id;

    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Voucher berhasil disimpan dan diposting.',
        'voucher_id', v_header_id,
        'reference_no', TRIM(p_reference_no),
        'total_debit', v_total_debit,
        'total_credit', v_total_credit,
        'posting_status', 'POSTED',
        'hash_checksum', v_checksum
    );
END;
$$;