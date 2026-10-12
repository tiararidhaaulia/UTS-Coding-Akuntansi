
-- UTS CODING AKUNTANSI - SOAL 2
-- Trigger otomatis untuk memperbarui stok
-- FOR UPDATE mencegah dua transaksi menjual stok yang sama

CREATE OR REPLACE FUNCTION public.trg_update_stock_and_journal()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    current_stock INT;
BEGIN
    -- Kunci baris barang agar transaksi bersamaan
    -- diproses secara bergantian
    SELECT stock_qty
    INTO current_stock
    FROM public.inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Barang dengan kode % tidak ditemukan.',
            NEW.item_id;
    END IF;

    IF NEW.trx_type = 'PURCHASE' THEN

        UPDATE public.inventory_items
        SET stock_qty = current_stock + NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'SALE' THEN

        IF current_stock < NEW.qty THEN
            RAISE EXCEPTION
                'Stok tidak mencukupi. Stok tersedia: %, jumlah penjualan: %.',
                current_stock,
                NEW.qty;
        END IF;

        UPDATE public.inventory_items
        SET stock_qty = current_stock - NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'ADJUSTMENT' THEN

        -- ADJUSTMENT dianggap sebagai hasil hitung fisik terbaru
        UPDATE public.inventory_items
        SET stock_qty = NEW.qty
        WHERE item_id = NEW.item_id;

    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_inventory_stock
BEFORE INSERT
ON public.inventory_transactions
FOR EACH ROW
EXECUTE FUNCTION public.trg_update_stock_and_journal();