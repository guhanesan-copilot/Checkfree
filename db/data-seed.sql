-- ============================================================
-- SAP CAP Payment Details - Sample Seed Data
-- Mirrors SAP TLOGF table data structure
-- ============================================================

-- Payment Runs
INSERT INTO com_sap_payments_PaymentRuns (
  PaymentRunID, RunDate, RunType, CompanyCode, PaymentMethod,
  RunDescription, Status, Currency, TotalAmount, PaymentCount, CreatedBy,
  createdAt, createdBy, modifiedAt, modifiedBy
) VALUES
  ('F110-2024-001', '2024-01-15', 'F110', '1000', 'T', 'January Vendor Payments', '04', 'USD', 245670.50, 12, 'JSMITH', datetime('now'), 'JSMITH', datetime('now'), 'JSMITH'),
  ('F110-2024-002', '2024-02-15', 'F110', '1000', 'C', 'February Check Run',      '04', 'USD', 125340.00,  8, 'MJONES', datetime('now'), 'MJONES', datetime('now'), 'MJONES'),
  ('F110-2024-003', '2024-03-01', 'DMEE', '2000', 'T', 'EU Wire Transfers',       '03', 'EUR', 389200.75, 15, 'AMULLER',datetime('now'), 'AMULLER',datetime('now'), 'AMULLER'),
  ('F110-2024-004', '2024-03-15', 'F110', '1000', 'V', 'Card Payment Run Q1',     '04', 'USD',  56890.25,  6, 'LDAVIS', datetime('now'), 'LDAVIS', datetime('now'), 'LDAVIS'),
  ('F110-2024-005', '2024-04-01', 'F110', '1000', 'T', 'April ACH Batch',         '02', 'USD', 178900.00, 10, 'JSMITH', datetime('now'), 'JSMITH', datetime('now'), 'JSMITH');

-- Payment Details
INSERT INTO com_sap_payments_PaymentDetails (
  PaymentID, PaymentRunID, VendorID, VendorName, DocumentNumber, FiscalYear,
  PostingDate, DueDate, CompanyCode, Currency, GrossAmount, DiscountAmount, NetAmount,
  PaymentMethod, BankCountry, BankKey, BankAccount, CardNumber, CardType,
  CardHolder, CardExpiry, IBAN, SwiftCode, PaymentRef, ClearingDoc,
  HouseBank, HouseBankAcct, Status, DataSensitivity,
  createdAt, createdBy, modifiedAt, modifiedBy
) VALUES
  -- Wire Transfers
  ('PAY-2024-000001','F110-2024-001','V0001000','Acme Supplies Inc.',       '1900000001','2024','2024-01-15','2024-01-15','1000','USD', 45200.00, 452.00, 44748.00,'T','US','021000021','123456789','','','','','US21BOFA0000000001234','BOFAUS3N','REF-ACM-001','CL900001','HB01','CHK1','04','H',datetime('now'),'JSMITH',datetime('now'),'JSMITH'),
  ('PAY-2024-000002','F110-2024-001','V0002000','Global Tech Partners',     '1900000002','2024','2024-01-15','2024-01-15','1000','USD', 32100.00, 321.00, 31779.00,'T','US','021000021','987654321','','','','','US64CITI0000000009876','CITIUS33','REF-GTP-001','CL900002','HB01','CHK1','04','H',datetime('now'),'JSMITH',datetime('now'),'JSMITH'),
  ('PAY-2024-000003','F110-2024-001','V0003000','Metro Office Solutions',   '1900000003','2024','2024-01-15','2024-01-20','1000','USD', 18750.00, 187.50, 18562.50,'T','US','026009593','456789012','','','','','US33CHAS0000000004567','CHASUS33','REF-MOS-001','CL900003','HB01','CHK1','04','M',datetime('now'),'JSMITH',datetime('now'),'JSMITH'),
  ('PAY-2024-000004','F110-2024-001','V0004000','Summit Freight Co.',       '1900000004','2024','2024-01-15','2024-01-25','1000','USD', 12500.00, 0.00,   12500.00,'T','US','121000358','789012345','','','','','US82WELL0000000007890','WFBIUS6S','REF-SFC-001','','HB01','CHK1','02','M',datetime('now'),'JSMITH',datetime('now'),'JSMITH'),
  -- Check Payments
  ('PAY-2024-000005','F110-2024-002','V0005000','Pinnacle Consulting LLC',  '1900000005','2024','2024-02-15','2024-02-15','1000','USD', 28900.00, 0.00,   28900.00,'C','US','','','','','','','','','CHK-0000245','','HB01','CHK1','04','L',datetime('now'),'MJONES',datetime('now'),'MJONES'),
  ('PAY-2024-000006','F110-2024-002','V0006000','Eagle Industrial Supply',  '1900000006','2024','2024-02-15','2024-02-20','1000','USD', 41200.00, 412.00, 40788.00,'C','US','','','','','','','','','CHK-0000246','','HB01','CHK1','04','L',datetime('now'),'MJONES',datetime('now'),'MJONES'),
  -- EU Wire Transfers
  ('PAY-2024-000007','F110-2024-003','V0007000','Müller GmbH',              '1900000007','2024','2024-03-01','2024-03-01','2000','EUR', 68500.00, 685.00, 67815.00,'T','DE','20010020','3456789012','','','','','DE89370400440532013000','COBADEFF','REF-MUL-001','CL900007','HB02','EUR1','03','H',datetime('now'),'AMULLER',datetime('now'),'AMULLER'),
  ('PAY-2024-000008','F110-2024-003','V0008000','Schneider & Co. KG',       '1900000008','2024','2024-03-01','2024-03-05','2000','EUR', 42100.00, 421.00, 41679.00,'T','DE','10010010','6789012345','','','','','DE75512108001245126199','DEUTDEDB','REF-SCH-001','CL900008','HB02','EUR1','03','H',datetime('now'),'AMULLER',datetime('now'),'AMULLER'),
  ('PAY-2024-000009','F110-2024-003','V0009000','Horizon Logistics SA',     '1900000009','2024','2024-03-01','2024-03-10','2000','EUR', 95600.00, 0.00,   95600.00,'T','FR','30003000','9012345678','','','','','FR7630006000011234567890189','BNPAFRPP','REF-HLG-001','','HB02','EUR1','03','H',datetime('now'),'AMULLER',datetime('now'),'AMULLER'),
  -- Card Payments (PCI-DSS sensitive)
  ('PAY-2024-000010','F110-2024-004','V0010000','TechParts Online Ltd.',    '1900000010','2024','2024-03-15','2024-03-15','1000','USD',  9850.00, 0.00,    9850.00,'V','US','','','4532015112830366','VISA','John M. Smith','03/2027','','','CARD-VISA-001','','HB01','CARD','04','H',datetime('now'),'LDAVIS',datetime('now'),'LDAVIS'),
  ('PAY-2024-000011','F110-2024-004','V0011000','CloudServices Pro',        '1900000011','2024','2024-03-15','2024-03-15','1000','USD', 14200.00, 0.00,   14200.00,'V','US','','','5425233430109903','MC',  'Sarah L. Johnson','11/2026','','','CARD-MC-001','','HB01','CARD','04','H',datetime('now'),'LDAVIS',datetime('now'),'LDAVIS'),
  ('PAY-2024-000012','F110-2024-004','V0012000','Premium Events Group',     '1900000012','2024','2024-03-15','2024-03-15','1000','USD', 22450.00, 0.00,   22450.00,'V','US','','','374251018720955','AMEX', 'Robert A. Davis','08/2025','','','CARD-AMEX-001','','HB01','CARD','04','H',datetime('now'),'LDAVIS',datetime('now'),'LDAVIS'),
  -- Pending
  ('PAY-2024-000013','F110-2024-005','V0001000','Acme Supplies Inc.',       '1900000013','2024','2024-04-01','2024-04-01','1000','USD', 52300.00, 523.00, 51777.00,'T','US','021000021','123456789','','','','','US21BOFA0000000001234','BOFAUS3N','REF-ACM-002','','HB01','CHK1','02','H',datetime('now'),'JSMITH',datetime('now'),'JSMITH'),
  ('PAY-2024-000014','F110-2024-005','V0013000','Vertex Software Solutions','1900000014','2024','2024-04-01','2024-04-15','1000','USD', 36400.00, 0.00,   36400.00,'T','US','026009593','234567890','','','','','US44CHAS0000000002345','CHASUS33','REF-VSS-001','','HB01','CHK1','01','M',datetime('now'),'JSMITH',datetime('now'),'JSMITH');

-- Card Types
INSERT INTO com_sap_payments_CardTypes (CardTypeCode, Description, LogoColor) VALUES
  ('VISA','Visa',           '#1A1F71'),
  ('MC',  'Mastercard',     '#EB001B'),
  ('AMEX','American Express','#007BC1'),
  ('DISC','Discover',       '#F76000');

-- Payment Methods
INSERT INTO com_sap_payments_PaymentMethods (MethodCode, Description, Icon) VALUES
  ('T','Bank Transfer / Wire', 'bank'),
  ('C','Check',                'receipt'),
  ('V','Corporate Card',       'credit-card'),
  ('B','Bank Direct Debit',    'arrows-repeat');
