
-- Cegah perubahan atau penghapusan header yang sudah POSTED.
CREATE OR REPLACE FUNCTION public.prevent_posted_header_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.posting_status = 'POSTED' THEN
        RAISE EXCEPTION
            'Jurnal POSTED tidak boleh diubah atau dihapus. Gunakan jurnal pembalik (reversal).';
    END IF;

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;

CREATE TRIGGER trg_protect_posted_header
BEFORE UPDATE OR DELETE ON public.journal_headers
FOR EACH ROW
EXECUTE FUNCTION public.prevent_posted_header_change();


-- Cegah penambahan, perubahan, atau penghapusan baris
-- jika header jurnal sudah POSTED.
CREATE OR REPLACE FUNCTION public.prevent_posted_line_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_header_id BIGINT;
    v_status VARCHAR(10);
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF NEW.header_id <> OLD.header_id THEN
            RAISE EXCEPTION
                'Baris jurnal tidak boleh dipindahkan ke header lain.';
        END IF;
        v_header_id := OLD.header_id;
    ELSIF TG_OP = 'DELETE' THEN
        v_header_id := OLD.header_id;
    ELSE
        v_header_id := NEW.header_id;
    END IF;

    SELECT posting_status INTO v_status
    FROM public.journal_headers
    WHERE id = v_header_id
    FOR UPDATE;

    IF v_status = 'POSTED' THEN
        RAISE EXCEPTION
            'Baris jurnal POSTED tidak boleh diubah atau dihapus. Gunakan jurnal pembalik.';
    END IF;

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;

CREATE TRIGGER trg_protect_posted_lines
BEFORE INSERT OR UPDATE OR DELETE ON public.journal_lines
FOR EACH ROW
EXECUTE FUNCTION public.prevent_posted_line_change();