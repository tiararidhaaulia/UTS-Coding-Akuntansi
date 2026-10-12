
-- UTS CODING AKUNTANSI - SOAL 2
-- Membuat tabel persediaan dan transaksi persediaan

CREATE TABLE public.inventory_items (
    item_id VARCHAR(10) PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_qty INT NOT NULL DEFAULT 0,
    unit_cost NUMERIC(15, 2) NOT NULL
        CHECK (unit_cost >= 0),

    CONSTRAINT chk_stock_nonnegative
        CHECK (stock_qty >= 0)
);

CREATE TABLE public.inventory_transactions (
    trx_id SERIAL PRIMARY KEY,
    item_id VARCHAR(10) NOT NULL,
    trx_type VARCHAR(20) NOT NULL
        CHECK (
            trx_type IN (
                'PURCHASE',
                'SALE',
                'ADJUSTMENT'
            )
        ),
    qty INT NOT NULL CHECK (qty > 0),
    trx_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_transaction_item
        FOREIGN KEY (item_id)
        REFERENCES public.inventory_items(item_id)
        ON DELETE RESTRICT
);