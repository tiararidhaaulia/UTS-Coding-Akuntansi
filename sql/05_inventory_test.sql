
-- UTS CODING AKUNTANSI - SOAL 2
-- Pengujian otomatis trigger persediaan
-- Data pengujian dibersihkan kembali setelah pengujian

DO $$
DECLARE
    test_stock INT;
    test_transaction_count INT;
    oversell_rejected BOOLEAN := FALSE;
BEGIN
    -- Bersihkan data pengujian sebelumnya jika ada
    DELETE FROM public.inventory_transactions
    WHERE item_id = 'UTSTEST01';

    DELETE FROM public.inventory_items
    WHERE item_id = 'UTSTEST01';

    -- Buat barang uji dengan stok awal nol
    INSERT INTO public.inventory_items
        (item_id, item_name, stock_qty, unit_cost)
    VALUES
        ('UTSTEST01', 'Barang Uji UTS', 0, 10000.00);

    -- Pembelian 5 unit: stok harus menjadi 5
    INSERT INTO public.inventory_transactions
        (item_id, trx_type, qty)
    VALUES
        ('UTSTEST01', 'PURCHASE', 5);

    -- Penjualan 2 unit: stok harus menjadi 3
    INSERT INTO public.inventory_transactions
        (item_id, trx_type, qty)
    VALUES
        ('UTSTEST01', 'SALE', 2);

    SELECT stock_qty
    INTO test_stock
    FROM public.inventory_items
    WHERE item_id = 'UTSTEST01';

    IF test_stock <> 3 THEN
        RAISE EXCEPTION
            'Pengujian gagal: stok seharusnya 3, tetapi %.',
            test_stock;
    END IF;

    -- Coba menjual 4 unit saat stok hanya 3
    BEGIN
        INSERT INTO public.inventory_transactions
            (item_id, trx_type, qty)
        VALUES
            ('UTSTEST01', 'SALE', 4);
    EXCEPTION WHEN OTHERS THEN
        oversell_rejected := TRUE;
    END;

    IF NOT oversell_rejected THEN
        RAISE EXCEPTION
            'Pengujian gagal: penjualan melebihi stok tidak ditolak.';
    END IF;

    -- Pastikan stok dan transaksi tidak berubah akibat penjualan gagal
    SELECT stock_qty
    INTO test_stock
    FROM public.inventory_items
    WHERE item_id = 'UTSTEST01';

    SELECT COUNT(*)
    INTO test_transaction_count
    FROM public.inventory_transactions
    WHERE item_id = 'UTSTEST01';

    IF test_stock <> 3 OR test_transaction_count <> 2 THEN
        RAISE EXCEPTION
            'Pengujian gagal: stok atau jumlah transaksi tidak sesuai.';
    END IF;

    -- Hapus seluruh data uji
    DELETE FROM public.inventory_transactions
    WHERE item_id = 'UTSTEST01';

    DELETE FROM public.inventory_items
    WHERE item_id = 'UTSTEST01';

    RAISE NOTICE
        'LULUS: pembelian, penjualan, dan pencegahan stok minus.';
END;
$$;