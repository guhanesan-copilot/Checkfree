'use strict';

const cds = require('@sap/cds');

module.exports = class PaymentService extends cds.ApplicationService {

  async init() {
    const { PaymentDetails, DownloadAuditLog } = this.entities;

    // ── Mask card/bank data on every PaymentDetails READ ──────────────────────
    this.after('READ', 'PaymentDetails', (results) => {
      const rows = Array.isArray(results) ? results : (results ? [results] : []);
      rows.forEach(row => {
        if (row.CardNumber) {
          row.MaskedCardNumber = maskCard(row.CardNumber);
          row.HasCard = true;
          row.CardNumber = row.MaskedCardNumber; // replace in payload
        } else {
          row.MaskedCardNumber = '';
          row.HasCard = false;
        }
        if (row.BankAccount) {
          row.MaskedBankAccount = '****' + row.BankAccount.slice(-4);
          row.BankAccount = row.MaskedBankAccount;
        } else {
          row.MaskedBankAccount = '';
        }
      });
    });

    // ── Action: downloadPayments ──────────────────────────────────────────────
    this.on('downloadPayments', async (req) => {
      const { paymentRunID, format = 'CSV', includeCards = false, justification } = req.data;

      if (includeCards && (!justification || justification.trim().length < 10)) {
        return req.error(400, 'A justification of at least 10 characters is required to include full card numbers.');
      }

      let query = SELECT.from(PaymentDetails);
      if (paymentRunID) query = query.where({ PaymentRunID: paymentRunID });

      const payments = await cds.run(query);
      if (!payments || payments.length === 0) {
        return req.error(404, 'No payment records found for the specified criteria.');
      }

      const processed = payments.map(p => {
        const r = { ...p };
        r.CardNumber    = (r.CardNumber && includeCards) ? r.CardNumber : maskCard(r.CardNumber);
        r.BankAccount   = r.BankAccount ? '****' + r.BankAccount.slice(-4) : '';
        r.StatusLabel   = getStatusLabel(r.Status);
        r.MethodLabel   = getMethodLabel(r.PaymentMethod);
        return r;
      });

      const timestamp = new Date().toISOString().slice(0, 10);
      const runSuffix = paymentRunID ? `-${paymentRunID}` : '';
      const fileName  = `payment-details${runSuffix}-${timestamp}.csv`;

      // Audit log
      await cds.run(INSERT.into(DownloadAuditLog).entries({
        UserID:          req.user?.id || 'ANONYMOUS',
        DownloadDate:    new Date().toISOString(),
        PaymentRunID:    paymentRunID || 'ALL',
        RecordsCount:    processed.length,
        Format:          format.toUpperCase(),
        IncludeFullCard: includeCards,
        IPAddress:       req.headers?.['x-forwarded-for'] || 'unknown',
        Justification:   justification || ''
      }));

      return {
        fileContent: generateCSV(processed),
        fileName,
        mimeType:    'text/csv',
        recordCount: processed.length
      };
    });

    // ── Action: revealCardNumber ──────────────────────────────────────────────
    this.on('revealCardNumber', async (req) => {
      const { paymentID, justification } = req.data;

      if (!justification || justification.trim().length < 10) {
        return req.error(400, 'Justification (min 10 chars) is required to reveal card numbers.');
      }

      const payment = await SELECT.one.from(PaymentDetails)
        .where({ PaymentID: paymentID })
        .columns('CardNumber', 'CardType', 'CardHolder', 'CardExpiry');

      if (!payment) return req.error(404, `Payment ${paymentID} not found.`);
      if (!payment.CardNumber) return req.error(422, 'This payment has no card number on record.');

      await cds.run(INSERT.into(DownloadAuditLog).entries({
        UserID:          req.user?.id || 'ANONYMOUS',
        DownloadDate:    new Date().toISOString(),
        PaymentRunID:    paymentID,
        RecordsCount:    1,
        Format:          'REVEAL',
        IncludeFullCard: true,
        IPAddress:       req.headers?.['x-forwarded-for'] || 'unknown',
        Justification:   justification
      }));

      return {
        cardNumber: payment.CardNumber,
        maskedCard: maskCard(payment.CardNumber),
        cardType:   payment.CardType,
        cardHolder: payment.CardHolder,
        expiry:     payment.CardExpiry
      };
    });

    // ── Function: getPaymentSummary ───────────────────────────────────────────
    this.on('getPaymentSummary', async (req) => {
      const { paymentRunID } = req.data;
      const where = paymentRunID ? { PaymentRunID: paymentRunID } : {};
      const rows  = await SELECT.from(PaymentDetails).where(where)
        .columns('Currency', 'NetAmount', 'PaymentMethod', 'Status');

      if (!rows.length) return JSON.stringify({ totalAmount: 0, paymentCount: 0, byMethod: [], byStatus: [] });

      const total   = rows.reduce((s, r) => s + (r.NetAmount || 0), 0);
      const methods = {}, statuses = {};
      rows.forEach(r => {
        if (!methods[r.PaymentMethod]) methods[r.PaymentMethod] = { method: r.PaymentMethod, description: getMethodLabel(r.PaymentMethod), count: 0, amount: 0 };
        methods[r.PaymentMethod].count++;
        methods[r.PaymentMethod].amount += (r.NetAmount || 0);
        if (!statuses[r.Status]) statuses[r.Status] = { status: r.Status, label: getStatusLabel(r.Status), count: 0 };
        statuses[r.Status].count++;
      });

      return JSON.stringify({
        totalAmount:  Math.round(total * 100) / 100,
        currency:     rows[0].Currency,
        paymentCount: rows.length,
        byMethod:     Object.values(methods),
        byStatus:     Object.values(statuses)
      });
    });

    await super.init();
  }
};

// ── Helpers ──────────────────────────────────────────────────────────────────
function maskCard(card) {
  if (!card) return '';
  const c = card.replace(/\D/g, '');
  const last4 = c.slice(-4);
  if (c.length === 15) return `****-******-${last4}`;
  return `****-****-****-${last4}`;
}

function getStatusLabel(code) {
  return { '01': 'Open', '02': 'Proposed', '03': 'Posted', '04': 'Cleared' }[code] || code;
}

function getMethodLabel(code) {
  return { T: 'Wire Transfer', C: 'Check', V: 'Corporate Card', B: 'Direct Debit' }[code] || code;
}

function generateCSV(records) {
  const headers = [
    'PaymentID','PaymentRunID','VendorID','VendorName','DocumentNumber',
    'FiscalYear','PostingDate','DueDate','CompanyCode','Currency',
    'GrossAmount','DiscountAmount','NetAmount','MethodLabel',
    'BankCountry','BankKey','BankAccount','CardNumber','CardType',
    'CardHolder','CardExpiry','IBAN','SwiftCode','PaymentRef',
    'ClearingDoc','HouseBank','HouseBankAcct','StatusLabel'
  ];
  const esc = v => {
    if (v === null || v === undefined) return '';
    const s = String(v);
    return s.includes(',') || s.includes('"') || s.includes('\n') ? `"${s.replace(/"/g,'""')}"` : s;
  };
  const rows = records.map(r => headers.map(h => esc(r[h])).join(','));
  return Buffer.from([headers.join(','), ...rows].join('\n'), 'utf-8').toString('base64');
}
