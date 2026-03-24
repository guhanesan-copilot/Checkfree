using com.sap.payments as payments from '../db/schema';

service PaymentService @(path: '/payment') {

  @readonly
  entity PaymentRuns as projection on payments.PaymentRuns {
    *,
    Payments
  };

  @readonly
  entity PaymentDetails as projection on payments.PaymentDetails {
    PaymentID,
    PaymentRunID,
    VendorID,
    VendorName,
    DocumentNumber,
    FiscalYear,
    PostingDate,
    DueDate,
    CompanyCode,
    Currency,
    GrossAmount,
    DiscountAmount,
    NetAmount,
    PaymentMethod,
    BankCountry,
    BankKey,
    BankAccount,
    CardNumber,
    CardType,
    CardHolder,
    CardExpiry,
    IBAN,
    SwiftCode,
    PaymentRef,
    ClearingDoc,
    HouseBank,
    HouseBankAcct,
    Status,
    DataSensitivity
  };

  @readonly
  entity CardTypes as projection on payments.CardTypes;

  @readonly
  entity PaymentMethods as projection on payments.PaymentMethods;

  entity DownloadAuditLog as projection on payments.DownloadAuditLog;

  action downloadPayments(
    paymentRunID  : String,
    format        : String,
    includeCards  : Boolean,
    justification : String
  ) returns {
    fileContent : String;
    fileName    : String;
    mimeType    : String;
    recordCount : Integer;
  };

  action revealCardNumber(
    paymentID     : String,
    justification : String
  ) returns {
    cardNumber : String;
    maskedCard : String;
    cardType   : String;
    cardHolder : String;
    expiry     : String;
  };

  function getPaymentSummary(paymentRunID : String) returns String;
}
