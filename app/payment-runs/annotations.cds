using PaymentService as service from '../../srv/payment-service';

// ── PaymentRuns field labels ───────────────────────────────────────────────
annotate service.PaymentRuns with {
  PaymentRunID   @title: 'Payment Run ID';
  RunDate        @title: 'Run Date';
  RunType        @title: 'Run Type';
  CompanyCode    @title: 'Company Code';
  PaymentMethod  @title: 'Payment Method';
  RunDescription @title: 'Description';
  Status         @title: 'Status';
  Currency       @title: 'Currency';
  TotalAmount    @title: 'Total Amount';
  PaymentCount   @title: 'Payments';
  createdBy      @title: 'Created By';
};

// ── PaymentRuns List Report ────────────────────────────────────────────────
annotate service.PaymentRuns with @(

  UI.SelectionFields: [ Status, RunType, CompanyCode ],

  UI.LineItem: [
    { $Type: 'UI.DataField', Value: PaymentRunID,   Label: 'Run ID'      },
    { $Type: 'UI.DataField', Value: RunDate,        Label: 'Run Date'    },
    { $Type: 'UI.DataField', Value: RunType,        Label: 'Type'        },
    { $Type: 'UI.DataField', Value: CompanyCode,    Label: 'Company'     },
    { $Type: 'UI.DataField', Value: RunDescription, Label: 'Description' },
    { $Type: 'UI.DataField', Value: PaymentCount,   Label: 'Payments'    },
    { $Type: 'UI.DataField', Value: TotalAmount,    Label: 'Total Amount'},
    { $Type: 'UI.DataField', Value: Currency,       Label: 'Currency'    },
    { $Type: 'UI.DataField', Value: Status,         Label: 'Status'      },
    { $Type: 'UI.DataField', Value: createdBy,      Label: 'Created By'  }
  ],

  // Object Page header
  UI.HeaderInfo: {
    TypeName:       'Payment Run',
    TypeNamePlural: 'Payment Runs',
    Title:       { $Type: 'UI.DataField', Value: PaymentRunID   },
    Description: { $Type: 'UI.DataField', Value: RunDescription }
  },

  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#HeaderKPIs', Label: 'Summary' }
  ],

  UI.FieldGroup #HeaderKPIs: {
    Data: [
      { $Type: 'UI.DataField', Value: Status       },
      { $Type: 'UI.DataField', Value: TotalAmount  },
      { $Type: 'UI.DataField', Value: Currency     },
      { $Type: 'UI.DataField', Value: PaymentCount }
    ]
  },

  // Object Page sections
  UI.Facets: [
    {
      $Type:  'UI.CollectionFacet',
      Label:  'Run Details',
      ID:     'RunDetails',
      Facets: [
        { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#General',   Label: 'General'   },
        { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Financial', Label: 'Financial' }
      ]
    },
    {
      $Type:  'UI.ReferenceFacet',
      Target: 'Payments/@UI.LineItem',
      Label:  'Payment Details',
      ID:     'PaymentDetails'
    }
  ],

  UI.FieldGroup #General: {
    Data: [
      { $Type: 'UI.DataField', Value: PaymentRunID   },
      { $Type: 'UI.DataField', Value: RunDate        },
      { $Type: 'UI.DataField', Value: RunType        },
      { $Type: 'UI.DataField', Value: CompanyCode    },
      { $Type: 'UI.DataField', Value: PaymentMethod  },
      { $Type: 'UI.DataField', Value: RunDescription },
      { $Type: 'UI.DataField', Value: createdBy      }
    ]
  },

  UI.FieldGroup #Financial: {
    Data: [
      { $Type: 'UI.DataField', Value: Currency     },
      { $Type: 'UI.DataField', Value: TotalAmount  },
      { $Type: 'UI.DataField', Value: PaymentCount }
    ]
  }
);

// ── PaymentDetails field labels ────────────────────────────────────────────
annotate service.PaymentDetails with {
  PaymentID      @title: 'Payment ID';
  PaymentRunID   @title: 'Payment Run';
  VendorID       @title: 'Vendor ID';
  VendorName     @title: 'Vendor Name';
  DocumentNumber @title: 'Document No.';
  FiscalYear     @title: 'Fiscal Year';
  PostingDate    @title: 'Posting Date';
  DueDate        @title: 'Due Date';
  CompanyCode    @title: 'Company Code';
  Currency       @title: 'Currency';
  GrossAmount    @title: 'Gross Amount';
  DiscountAmount @title: 'Discount';
  NetAmount      @title: 'Net Amount';
  PaymentMethod  @title: 'Method';
  BankCountry    @title: 'Bank Country';
  BankKey        @title: 'Routing No.';
  BankAccount    @title: 'Bank Account';
  CardNumber     @title: 'Card Number';
  CardType       @title: 'Card Type';
  CardHolder     @title: 'Card Holder';
  CardExpiry     @title: 'Card Expiry';
  IBAN           @title: 'IBAN';
  SwiftCode      @title: 'SWIFT / BIC';
  PaymentRef     @title: 'Payment Ref.';
  ClearingDoc    @title: 'Clearing Doc.';
  HouseBank      @title: 'House Bank';
  HouseBankAcct  @title: 'HB Account';
  Status         @title: 'Status';
  DataSensitivity @title: 'Sensitivity';
};

// ── PaymentDetails List Item (sub-table on Run Object Page) ───────────────
annotate service.PaymentDetails with @(

  UI.SelectionFields: [ PaymentRunID, PaymentMethod, Status ],

  UI.LineItem: [
    { $Type: 'UI.DataField', Value: PaymentID,      Label: 'Payment ID'   },
    { $Type: 'UI.DataField', Value: VendorName,     Label: 'Vendor'       },
    { $Type: 'UI.DataField', Value: DocumentNumber, Label: 'Document'     },
    { $Type: 'UI.DataField', Value: PostingDate,    Label: 'Posting Date' },
    { $Type: 'UI.DataField', Value: NetAmount,      Label: 'Net Amount'   },
    { $Type: 'UI.DataField', Value: Currency,       Label: 'Currency'     },
    { $Type: 'UI.DataField', Value: PaymentMethod,  Label: 'Method'       },
    { $Type: 'UI.DataField', Value: CardNumber,     Label: 'Card Number'  },
    { $Type: 'UI.DataField', Value: CardType,       Label: 'Card Type'    },
    { $Type: 'UI.DataField', Value: Status,         Label: 'Status'       }
  ],

  // Object Page
  UI.HeaderInfo: {
    TypeName:       'Payment',
    TypeNamePlural: 'Payments',
    Title:       { $Type: 'UI.DataField', Value: PaymentID  },
    Description: { $Type: 'UI.DataField', Value: VendorName }
  },

  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#PaymentAmounts', Label: 'Amounts' }
  ],

  UI.FieldGroup #PaymentAmounts: {
    Data: [
      { $Type: 'UI.DataField', Value: GrossAmount },
      { $Type: 'UI.DataField', Value: NetAmount   },
      { $Type: 'UI.DataField', Value: Currency    },
      { $Type: 'UI.DataField', Value: Status      }
    ]
  },

  UI.Facets: [
    {
      $Type:  'UI.CollectionFacet',
      Label:  'Payment Information',
      ID:     'PaymentInfo',
      Facets: [
        { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#PayGeneral',   Label: 'General'   },
        { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#PayFinancial', Label: 'Financial' }
      ]
    },
    {
      $Type:  'UI.CollectionFacet',
      Label:  'Banking and Card Details',
      ID:     'BankCard',
      Facets: [
        { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#BankDetails', Label: 'Bank Details' },
        { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#CardDetails', Label: 'Card Details' }
      ]
    }
  ],

  UI.FieldGroup #PayGeneral: {
    Data: [
      { $Type: 'UI.DataField', Value: PaymentID      },
      { $Type: 'UI.DataField', Value: PaymentRunID   },
      { $Type: 'UI.DataField', Value: VendorID       },
      { $Type: 'UI.DataField', Value: VendorName     },
      { $Type: 'UI.DataField', Value: DocumentNumber },
      { $Type: 'UI.DataField', Value: FiscalYear     },
      { $Type: 'UI.DataField', Value: PostingDate    },
      { $Type: 'UI.DataField', Value: DueDate        },
      { $Type: 'UI.DataField', Value: CompanyCode    },
      { $Type: 'UI.DataField', Value: PaymentMethod  },
      { $Type: 'UI.DataField', Value: PaymentRef     },
      { $Type: 'UI.DataField', Value: ClearingDoc    }
    ]
  },

  UI.FieldGroup #PayFinancial: {
    Data: [
      { $Type: 'UI.DataField', Value: Currency       },
      { $Type: 'UI.DataField', Value: GrossAmount    },
      { $Type: 'UI.DataField', Value: DiscountAmount },
      { $Type: 'UI.DataField', Value: NetAmount      },
      { $Type: 'UI.DataField', Value: HouseBank      },
      { $Type: 'UI.DataField', Value: HouseBankAcct  }
    ]
  },

  UI.FieldGroup #BankDetails: {
    Data: [
      { $Type: 'UI.DataField', Value: BankCountry },
      { $Type: 'UI.DataField', Value: BankKey     },
      { $Type: 'UI.DataField', Value: BankAccount },
      { $Type: 'UI.DataField', Value: IBAN        },
      { $Type: 'UI.DataField', Value: SwiftCode   }
    ]
  },

  UI.FieldGroup #CardDetails: {
    Data: [
      { $Type: 'UI.DataField', Value: CardNumber     },
      { $Type: 'UI.DataField', Value: CardType       },
      { $Type: 'UI.DataField', Value: CardHolder     },
      { $Type: 'UI.DataField', Value: CardExpiry     },
      { $Type: 'UI.DataField', Value: DataSensitivity}
    ]
  }
);
