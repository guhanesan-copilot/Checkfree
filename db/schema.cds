namespace com.sap.payments;

using { cuid, managed } from '@sap/cds/common';

// Payment Run Header (mirrors SAP F110 TLOGF structure)
// Note: managed aspect already provides createdAt, createdBy, modifiedAt, modifiedBy
entity PaymentRuns : managed {
  key PaymentRunID    : String(20);
      RunDate         : Date;
      RunType         : String(4);       // F110, DMEE, etc.
      CompanyCode     : String(4);       // BUKRS
      PaymentMethod   : String(1);       // UZAWE
      RunDescription  : String(100);
      Status          : String(2);       // 01=Open 02=Proposed 03=Posted 04=Done
      Currency        : String(5);
      TotalAmount     : Decimal(17,2);
      PaymentCount    : Integer;
      Payments        : Association to many PaymentDetails on Payments.PaymentRunID = $self.PaymentRunID;
}

// Payment Details (TLOGF line items - card and bank data)
entity PaymentDetails : managed {
  key PaymentID       : String(30);
      PaymentRunID    : String(20);
      VendorID        : String(10);      // LIFNR
      VendorName      : String(80);
      DocumentNumber  : String(10);      // BELNR
      FiscalYear      : String(4);       // GJAHR
      PostingDate     : Date;            // BUDAT
      DueDate         : Date;            // ZFBDT
      CompanyCode     : String(4);       // BUKRS
      Currency        : String(5);
      GrossAmount     : Decimal(17,2);   // WRBTR
      DiscountAmount  : Decimal(17,2);   // SKFBT
      NetAmount       : Decimal(17,2);
      PaymentMethod   : String(1);       // UZAWE
      BankCountry     : String(3);
      BankKey         : String(15);      // BANKL
      BankAccount     : String(18);      // BANKN
      CardNumber      : String(19);      // PCI-DSS - masked in service
      CardType        : String(4);       // VISA MC AMEX DISC
      CardHolder      : String(60);
      CardExpiry      : String(7);
      IBAN            : String(34);
      SwiftCode       : String(11);
      PaymentRef      : String(20);      // VBLNR
      ClearingDoc     : String(10);      // AUGBL
      HouseBank       : String(5);       // HBKID
      HouseBankAcct   : String(5);       // HKTID
      Status          : String(2);
      ErrorMessage    : String(200);
      DataSensitivity : String(1) default 'H';
}

// Card type reference
entity CardTypes {
  key CardTypeCode : String(4);
      Description  : String(30);
      LogoColor    : String(7);
}

// Payment method reference
entity PaymentMethods {
  key MethodCode  : String(1);
      Description : String(30);
      Icon        : String(30);
}

// Download + reveal audit log (PCI-DSS requirement)
entity DownloadAuditLog : cuid, managed {
      UserID          : String(12);
      DownloadDate    : DateTime;
      PaymentRunID    : String(20);
      RecordsCount    : Integer;
      Format          : String(6);
      IncludeFullCard : Boolean;
      IPAddress       : String(45);
      Justification   : String(200);
}
