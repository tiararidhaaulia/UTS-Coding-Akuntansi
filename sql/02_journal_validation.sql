
-- UTS CODING AKUNTANSI - SOAL 1
-- Validasi keseimbangan jurnal sebelum POSTED

CREATE OR REPLACE FUNCTION public.validate_journal_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    line_count BIGINT;
    total_debit NUMERIC(15, 2);
    total_credit NUMERIC(15, 2);
BEGIN
    IF NEW.posting_status = 'POSTED' THEN
        SELECT
            COUNT(*),
            COALESCE(SUM(debit), 0),
            COALESCE(SUM(credit), 0)
        INTO
            line_count,
            total_debit,
            total_credit
        FROM public.journal_lines
        WHERE header_id = NEW.id;

        IF line_count = 0 THEN
            RAISE EXCEPTION
                'Jurnal tidak dapat diposting karena belum memiliki baris.';
        END IF;

        IF total_debit <> total_credit THEN
            RAISE EXCEPTION
                'Jurnal tidak seimbang. Total debit: %, total kredit: %.',
                total_debit,
                total_credit;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validate_journal_balance
BEFORE INSERT OR UPDATE OF posting_status
ON public.journal_headers
FOR EACH ROW
EXECUTE FUNCTION public.validate_journal_balance();