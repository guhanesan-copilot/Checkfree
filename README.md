# SAP CAP – Payment Details Download (Fiori Elements)

A **SAP Cloud Application Programming Model (CAP)** project with a proper
**SAP Fiori Elements** frontend — no freestyle UI5 code. All screens are
driven by `@UI` annotations in CDS.

---

## Quick Start

```bash
npm install
cds deploy --to sqlite   # creates DB and seeds CSV data
cds watch                # http://localhost:4004
```

Open the Fiori Elements app:
```
http://localhost:4004/payment-runs/webapp/index.html
```

OData service:
```
http://localhost:4004/payment/
http://localhost:4004/payment/$metadata
```

---

## Project Structure

```
sap-cap-payment-details/
├── .cdsrc.json
├── package.json
│
├── db/
│   ├── schema.cds                    ← Entities: PaymentRuns, PaymentDetails, etc.
│   └── data/                         ← Auto-seeded on "cds deploy"
│       ├── com.sap.payments-PaymentRuns.csv
│       ├── com.sap.payments-PaymentDetails.csv
│       ├── com.sap.payments-CardTypes.csv
│       └── com.sap.payments-PaymentMethods.csv
│
├── srv/
│   ├── payment-service.cds           ← OData V4 service + actions
│   └── payment-service.js            ← Card masking (@after handler), download, audit
│
└── app/
    └── payment-runs/
        ├── annotations.cds           ← ALL UI annotations (@UI.LineItem, @UI.Facets, etc.)
        ├── ext/
        │   └── controller/
        │       └── ListReportExt.js  ← Controller extension for Download actions
        └── webapp/
            ├── index.html
            ├── Component.js          ← Extends sap.fe.core.AppComponent
            ├── manifest.json         ← Fiori Elements routing (ListReport + ObjectPage)
            └── i18n/
                └── i18n.properties
```

---

## Fiori Elements Screens

### List Report – Payment Runs
- Filter bar: Status, Run Type, Company Code, Run Date
- Responsive table with export
- Criticality-coloured Status column
- Click a row → Object Page

### Object Page – Payment Run
- Header: Run ID, Description, Status (criticality), Total Amount, Payment Count
- Sections: General Information, Financial Details
- Sub-table: Payment Details (all line items for this run)
  - Custom toolbar buttons: **Download CSV**, **Download XLSX**, **Download with Cards**

### Object Page – Payment Detail
- Header: Payment ID, Vendor, Status, Amounts
- Sections: General, Financial, Bank Details, Card Details
- Card Number shown masked (`****-****-****-1234`) via `@after` service handler

---

## Key Design Decisions

| Concern | Approach |
|---|---|
| No freestyle views | All screens via `sap.fe.templates.ListReport` + `ObjectPage` |
| No freestyle controllers | `Component.js` extends `sap.fe.core.AppComponent` only |
| Custom actions | Controller extension `ListReportExt.js` registered in `manifest.json` |
| Card masking | `@after READ` handler in `payment-service.js` — never in CDS |
| UI layout | Driven entirely by `annotations.cds` (`@UI.LineItem`, `@UI.Facets`, `@UI.FieldGroup`) |
| Audit trail | Every download/reveal writes to `DownloadAuditLog` entity |

---

## PCI-DSS / Card Security

- `CardNumber` is **always masked** in all OData reads
- Full card only returned by `revealCardNumber` action (requires justification ≥ 10 chars)
- "Download with Full Cards" button shows a guarded dialog before calling the action
- All events logged to `DownloadAuditLog`

---

## Deploy to SAP BTP

```bash
cds build --production
# Bind HANA, HTML5 Repo, and Destination services in BTP cockpit
mbt build
cf deploy mta_archives/*.mtar
```
