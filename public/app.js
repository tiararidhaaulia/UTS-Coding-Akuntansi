
const accounts = [
  { code: "101", name: "Kas" },
  { code: "102", name: "Bank" },
  { code: "501", name: "Beban Gaji" },
  { code: "502", name: "Beban Listrik" },
  { code: "503", name: "Beban Perlengkapan" },
  { code: "201", name: "Utang Usaha" },
  { code: "301", name: "Modal" }
];

const form = document.getElementById("voucherForm");
const journalLines = document.getElementById("journalLines");
const addLineBtn = document.getElementById("addLineBtn");
const submitBtn = document.getElementById("submitBtn");
const totalDebitElement = document.getElementById("totalDebit");
const totalCreditElement = document.getElementById("totalCredit");
const balanceStatus = document.getElementById("balanceStatus");
const result = document.getElementById("result");

function formatRupiah(value) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 2
  }).format(value);
}

function createAccountOptions() {
  return `
    <option value="">-- Pilih akun --</option>
    ${accounts.map(account => `
      <option value="${account.code}">
        ${account.code} - ${account.name}
      </option>
    `).join("")}
  `;
}

function addJournalLine() {
  const row = document.createElement("div");
  row.className = "journal-line";

  row.innerHTML = `
    <div class="form-group">
      <label>Akun</label>
      <select class="account-code" required>
        ${createAccountOptions()}
      </select>
    </div>

    <div class="form-group">
      <label>Debit (Rp)</label>
      <input
        type="number"
        class="debit"
        min="0"
        step="0.01"
        value="0"
        required
      >
    </div>

    <div class="form-group">
      <label>Kredit (Rp)</label>
      <input
        type="number"
        class="credit"
        min="0"
        step="0.01"
        value="0"
        required
      >
    </div>

    <button type="button" class="remove-line">
      Hapus Baris
    </button>
  `;

  journalLines.appendChild(row);

  row.querySelectorAll("select, input").forEach(input => {
    input.addEventListener("input", updateBalance);
    input.addEventListener("change", updateBalance);
  });

  row.querySelector(".remove-line").addEventListener("click", () => {
    row.remove();
    updateBalance();
  });

  updateBalance();
}

function getJournalData() {
  return [...journalLines.querySelectorAll(".journal-line")].map(row => ({
    accountCode: row.querySelector(".account-code").value,
    debit: Number(row.querySelector(".debit").value || 0),
    credit: Number(row.querySelector(".credit").value || 0)
  }));
}

function updateBalance() {
  const lines = getJournalData();

  const totalDebit = lines.reduce((sum, line) => sum + line.debit, 0);
  const totalCredit = lines.reduce((sum, line) => sum + line.credit, 0);

  totalDebitElement.textContent = formatRupiah(totalDebit);
  totalCreditElement.textContent = formatRupiah(totalCredit);

  const validLines =
    lines.length >= 2 &&
    lines.every(line =>
      line.accountCode &&
      Number.isFinite(line.debit) &&
      Number.isFinite(line.credit) &&
      line.debit >= 0 &&
      line.credit >= 0 &&
      (line.debit > 0 || line.credit > 0) &&
      (line.debit === 0 || line.credit === 0)
    );

  const balanced =
    Math.round(totalDebit * 100) === Math.round(totalCredit * 100);

  const valid = validLines && balanced && totalDebit > 0;

  if (!validLines) {
    balanceStatus.textContent =
      "Lengkapi minimal 2 baris jurnal. Setiap baris harus memiliki akun dan nilai yang valid.";
  } else if (!balanced) {
    balanceStatus.textContent = "Jurnal belum seimbang.";
  } else {
    balanceStatus.textContent = "Jurnal seimbang dan siap disimpan.";
  }

  submitBtn.disabled = !valid;
  return valid;
}

addLineBtn.addEventListener("click", addJournalLine);

form.addEventListener("submit", async event => {
  event.preventDefault();

  if (!updateBalance()) {
    return;
  }

  const transactionDate =
    document.getElementById("transactionDate").value;
  const referenceNo =
    document.getElementById("referenceNo").value.trim();
  const description =
    document.getElementById("description").value.trim();
  const cashFlowActivity =
    document.getElementById("cashFlowActivity").value;

  if (
    !transactionDate ||
    !referenceNo ||
    !description ||
    !cashFlowActivity
  ) {
    result.textContent = "Lengkapi semua informasi voucher.";
    return;
  }

  const payload = {
    transactionDate,
    referenceNo,
    description,
    cashFlowActivity,
    lines: getJournalData()
  };

  submitBtn.disabled = true;
  result.textContent = "Menyimpan voucher...";

  try {
    const response = await fetch("/api/vouchers", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(payload)
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || data.message || "Voucher gagal disimpan.");
    }

    result.textContent = JSON.stringify(data, null, 2);
  } catch (error) {
    result.textContent = `Terjadi kesalahan: ${error.message}`;
  } finally {
    updateBalance();
  }
});

addJournalLine();
addJournalLine();