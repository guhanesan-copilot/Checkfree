sap.ui.define([
  'sap/ui/core/mvc/ControllerExtension',
  'sap/m/MessageBox',
  'sap/m/MessageToast',
  'sap/m/Dialog',
  'sap/m/Button',
  'sap/m/VBox',
  'sap/m/Text',
  'sap/m/Label',
  'sap/m/Input',
  'sap/ui/core/BusyIndicator'
], function (
  ControllerExtension, MessageBox, MessageToast,
  Dialog, Button, VBox, Text, Label, Input, BusyIndicator
) {
  'use strict';

  return ControllerExtension.extend(
    'com.sap.payments.paymentruns.ext.controller.ListReportExt', {

    // ── Get current PaymentRunID from Object Page binding context ─────────
    _getRunId: function (oEvent) {
      const oView    = oEvent.getSource().getParent();
      const oContext = oView && oView.getBindingContext
        ? oView.getBindingContext()
        : null;
      return oContext ? oContext.getProperty('PaymentRunID') : null;
    },

    // ── Download CSV (masked cards) ───────────────────────────────────────
    onDownloadCSV: function (oEvent) {
      this._download(this._getRunId(oEvent), 'CSV', false, null);
    },

    // ── Download XLSX (masked cards) ─────────────────────────────────────
    onDownloadXLSX: function (oEvent) {
      this._download(this._getRunId(oEvent), 'XLSX', false, null);
    },

    // ── Download with full card numbers (PCI-DSS guarded) ────────────────
    onDownloadWithCards: function (oEvent) {
      const sRunId = this._getRunId(oEvent);
      let sJustification = '';

      const oDialog = new Dialog({
        title:  'Download with Full Card Numbers',
        state:  'Warning',
        type:   'Message',
        content: [
          new VBox({
            class: 'sapUiSmallMargin',
            items: [
              new Text({
                text: 'Full unmasked card numbers will be included. '
                    + 'All downloads are logged and audited per PCI-DSS policy.'
              }).addStyleClass('sapUiSmallMarginBottom'),
              new Label({ text: 'Business Justification', required: true }),
              new Input({
                width:       '100%',
                maxLength:   200,
                placeholder: 'Reason for requiring full card numbers (min 10 chars)...',
                liveChange:  function (e) { sJustification = e.getParameter('value'); }
              })
            ]
          })
        ],
        beginButton: new Button({
          text:  'Download',
          type:  'Emphasized',
          press: () => {
            if (!sJustification || sJustification.trim().length < 10) {
              MessageToast.show('Please enter a justification of at least 10 characters.');
              return;
            }
            oDialog.close();
            this._download(sRunId, 'CSV', true, sJustification);
          }
        }),
        endButton: new Button({
          text:  'Cancel',
          press: () => oDialog.close()
        }),
        afterClose: () => oDialog.destroy()
      });

      oDialog.open();
    },

    // ── Core download logic ───────────────────────────────────────────────
    _download: function (sRunId, sFormat, bIncludeCards, sJustification) {
      BusyIndicator.show(0);

      const oModel   = sap.ui.getCore().byId('container-PaymentRunsApp')
                        ?.getModel() || sap.ui.getCore().getModel();
      const oContext = oModel.bindContext('/downloadPayments(...)');

      oContext.setParameter('paymentRunID',  sRunId || '');
      oContext.setParameter('format',        sFormat);
      oContext.setParameter('includeCards',  bIncludeCards);
      oContext.setParameter('justification', sJustification || '');

      oContext.execute()
        .then(() => {
          const oResult     = oContext.getBoundContext().getObject();
          const { fileContent, fileName, mimeType, recordCount } = oResult;

          if (!fileContent) throw new Error('Server returned empty file.');

          // Decode base64 and trigger browser download
          const binary = atob(fileContent);
          const bytes  = new Uint8Array(binary.length);
          for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);

          const blob = new Blob([bytes], { type: mimeType });
          const url  = URL.createObjectURL(blob);
          const a    = document.createElement('a');
          a.href     = url;
          a.download = fileName;
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(url);

          MessageToast.show(`Downloaded ${recordCount} record(s) — ${fileName}`);
        })
        .catch(err => {
          MessageBox.error('Download failed: ' + (err.message || String(err)));
        })
        .finally(() => BusyIndicator.hide());
    }
  });
});
