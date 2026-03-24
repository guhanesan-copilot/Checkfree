sap.ui.define([
    'sap/m/MessageBox',
    'sap/m/MessageToast',
    'sap/ui/core/BusyIndicator'
], function (MessageBox, MessageToast, BusyIndicator) {
    'use strict';

    /**
     * DownloadHelper
     * Calls the CAP downloadPayments action and triggers a browser file download.
     */
    return {

        /**
         * @param {sap.ui.core.mvc.View} oView  - Current view (for model access)
         * @param {string|null}          sRunId - Payment run ID (null = all runs)
         * @param {string}               sFormat - 'CSV' or 'XLSX'
         * @param {boolean}              bIncludeCards - Include full card numbers
         * @param {string}               [sJustification] - Required when bIncludeCards
         */
        download: function (oView, sRunId, sFormat, bIncludeCards, sJustification) {
            BusyIndicator.show(0);

            const oModel   = oView.getModel();
            const oContext = oModel.bindContext('/downloadPayments(...)');

            oContext.setParameter('paymentRunID',  sRunId || '');
            oContext.setParameter('format',        sFormat);
            oContext.setParameter('includeCards',  bIncludeCards || false);
            oContext.setParameter('justification', sJustification || '');

            oContext.execute()
                .then(() => {
                    const oResult = oContext.getBoundContext().getObject();
                    const { fileContent, fileName, mimeType, recordCount } = oResult;

                    if (!fileContent) {
                        throw new Error('Empty file received from server.');
                    }

                    // Decode base64 and trigger browser download
                    this._triggerDownload(fileContent, fileName, mimeType);

                    MessageToast.show(
                        `Downloaded ${recordCount} record(s) as ${fileName}`
                    );
                })
                .catch((oErr) => {
                    const sMsg = oErr.message || oErr.responseText || 'Download failed.';
                    MessageBox.error(`Download Error: ${sMsg}`);
                })
                .finally(() => BusyIndicator.hide());
        },

        /**
         * Decodes base64 string and triggers file download in browser
         */
        _triggerDownload: function (sBase64, sFileName, sMimeType) {
            try {
                // Decode base64 content
                const sBinary = atob(sBase64);
                const aBytes  = new Uint8Array(sBinary.length);
                for (let i = 0; i < sBinary.length; i++) {
                    aBytes[i] = sBinary.charCodeAt(i);
                }

                const oBlob = new Blob([aBytes], { type: sMimeType });
                const sUrl  = URL.createObjectURL(oBlob);

                const oLink    = document.createElement('a');
                oLink.href     = sUrl;
                oLink.download = sFileName;
                document.body.appendChild(oLink);
                oLink.click();
                document.body.removeChild(oLink);
                URL.revokeObjectURL(sUrl);
            } catch (e) {
                sap.m.MessageBox.error('Could not create download file: ' + e.message);
            }
        }
    };
});
