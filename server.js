
require("dotenv").config();

const express = require("express");
const path = require("path");
const { createClient } = require("@supabase/supabase-js");

const app = express();
const PORT = process.env.PORT || 3000;

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error(
    "SUPABASE_URL dan SUPABASE_SERVICE_ROLE_KEY harus diatur di file .env"
  );
}

const supabase = createClient(supabaseUrl, supabaseKey);

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

app.get("/api/health", (req, res) => {
  res.json({ success: true, message: "Backend berjalan." });
});

app.post("/api/vouchers", async (req, res) => {
  try {
    const {
      transactionDate,
      referenceNo,
      description,
      cashFlowActivity,
      lines
    } = req.body;

    const allowedActivities = [
      "OPERATING",
      "INVESTING",
      "FINANCING"
    ];

    if (
      !transactionDate ||
      !referenceNo?.trim() ||
      !description?.trim() ||
      !allowedActivities.includes(cashFlowActivity)
    ) {
      return res.status(400).json({
        success: false,
        error: "Data voucher atau kategori aktivitas arus kas tidak valid."
      });
    }

    if (!Array.isArray(lines) || lines.length < 2) {
      return res.status(400).json({
        success: false,
        error: "Voucher harus memiliki minimal dua baris jurnal."
      });
    }

    let totalDebit = 0;
    let totalCredit = 0;

    for (const line of lines) {
      if (
        !line.accountCode ||
        !Number.isFinite(line.debit) ||
        !Number.isFinite(line.credit) ||
        line.debit < 0 ||
        line.credit < 0 ||
        (line.debit === 0 && line.credit === 0) ||
        (line.debit > 0 && line.credit > 0)
      ) {
        return res.status(400).json({
          success: false,
          error: "Ada baris jurnal yang tidak valid."
        });
      }

      totalDebit += line.debit;
      totalCredit += line.credit;
    }

    totalDebit = Math.round(totalDebit * 100) / 100;
    totalCredit = Math.round(totalCredit * 100) / 100;

    if (
      totalDebit <= 0 ||
      totalDebit !== totalCredit
    ) {
      return res.status(400).json({
        success: false,
        error: "Total debit harus sama dengan total kredit."
      });
    }

    const { data, error } = await supabase.rpc(
      "create_cash_voucher",
      {
        p_reference_no: referenceNo.trim(),
        p_transaction_date: transactionDate,
        p_description: description.trim(),
        p_lines: lines.map(line => ({
          account_code: line.accountCode,
          debit: line.debit,
          credit: line.credit
        })),
        p_cash_flow_activity: cashFlowActivity
      }
    );

    if (error) {
      console.error("Supabase RPC error:", error.message);

      return res.status(400).json({
        success: false,
        error: error.message
      });
    }

    return res.status(201).json(data);
  } catch (error) {
    console.error("Server error:", error.message);

    return res.status(500).json({
      success: false,
      error: "Terjadi kesalahan pada server."
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});