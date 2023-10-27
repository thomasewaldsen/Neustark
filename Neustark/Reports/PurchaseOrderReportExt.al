reportextension 50100 PurchaseOrderPageExt extends 1322
{
    dataset
    {
        add("Purchase Header")
        {
            column(ShipmentDate; ShipmentDate)
            { }
            column(ShipmentDate_Lbl; ShipmentDate_Lbl)
            { }
            column(Quote_No_; "Quote No.")
            { }
            column(QuoteNo_Lbl; QuoteNo_Lbl)
            { }
            column(Purchase_Code_Lbl; Purchaser_Code_Lbl)
            { }
            column(Purchaser_Code; "Purchaser Code")
            { }
            column(PurchaserName; PurchaserName)
            { }
            column(PurchaserPhoneNo; PurchaserPhoneNo)
            { }
            column(PurchaserEMail; PurchaserEMail)
            { }
            column(Your_Reference; "Your Reference")
            { }
            column(Your_Reference_Lbl; Your_Reference_Lbl)
            { }
            column(IntroductionText; Einleitung)
            { }
            column(SenShipToTitle; SenShipToTitle)
            { }
            column(SenShipToName; SenShipToName)
            { }
            column(SenShipToAddr; SenShipToAddr)
            { }
            column(SenShipToCityPostCode; SenShipToCityPostCode)
            { }
            column(SenBelegdatum_Lbl; SenBelegdatum)
            { }
            column(SenLieferbedingung_Lbl; SenLieferbedingung)
            { }
            column(SenZahlungsbedingung_Lbl; SenZahlungsbedingung)
            { }
            column(SenTitle_Lbl; SenTitle)
            { }
            column(SenKontoNr_Lbl; SenKontoNr)
            { }
            column(SenMWSTNr_Lbl; SenMWSTNr)
            { }
            column(SenBeschreibung_Lbl; SenBeschreibung)
            { }
            column(SenMenge_Lbl; SenMenge)
            { }
            column(SenEinheit_Lbl; SenEinheit)
            { }
            column(SenEinheitspreis_Lbl; SenEinheitspreis)
            { }
            column(SenGesamtOhneMWST_Lbl; SenGesamtOhneMWST)
            { }
            column(SenMWSTProzent_Lbl; SenMWSTProzent)
            { }
            column(SenPaymentTerms; SenPaymentTerms)
            { }
            column(SenArtikelRef_Lbl; SenArtikelRef_Lbl)
            { }
            Column(SenBuyFromCountryRegion; SenBuyFromCountryRegion)
            { }
            column(SenShipToCountryRegion; SenShipToCountryRegion)
            { }
            column(SenBuyFromVendorName; SenBuyFromVendorName)
            { }
            column(SenBuyFromVendorAddress; SenBuyFromVendorAddress)
            { }
            column(SenBuyFromVendorAdress2; SenBuyFromVendorAdress2)
            { }
            column(SenBuyFromVendorPLZOrt; SenBuyFromVendorPLZOrt)
            { }
        }
        modify("Purchase Header")
        {
            trigger OnBeforeAfterGetRecord()
            var
                CompanyInfoRec: Record "Company Information";
                CustomerRec: Record Customer;
                SalesPersonPurchaserRec: Record "Salesperson/Purchaser";
                PaymentTermTranslationRec: Record "Payment Term Translation";
                CountryRegionRec: Record "Country/Region";
                VendorRec: Record Vendor;
            begin
                CompanyInfoRec.Get();
                PurchasesPayablesSetupRec.GetRecordOnce();

                if not ("Buy-from Vendor No." = '') then begin
                    VendorRec.SetRange("No.", "Buy-from Vendor No.");
                    if VendorRec.FindFirst() then begin
                        SenBuyFromVendorName := VendorRec.Name;
                        SenBuyFromVendorAddress := VendorRec.Address;
                        SenBuyFromVendorAdress2 := VendorRec."Address 2";
                        SenBuyFromVendorPLZOrt := VendorRec."Post Code" + ' ' + VendorRec.City;
                    end;
                end;

                if "Buy-from Country/Region Code" <> '' then begin
                    CountryRegionRec.SetRange(Code, "Buy-from Country/Region Code");
                    if CountryRegionRec.FindFirst() then
                        SenBuyFromCountryRegion := CountryRegionRec.Name;
                end;

                if "Ship-to Country/Region Code" <> '' then begin
                    CountryRegionRec.Reset();
                    CountryRegionRec.SetRange(Code, "Ship-to Country/Region Code");
                    if CountryRegionRec.FindFirst() then
                        SenShipToCountryRegion := CountryRegionRec.Name;
                end
                else begin
                    CountryRegionRec.Reset();
                    CountryRegionRec.SetRange(Code, CompanyInfoRec."Country/Region Code");
                    if CountryRegionRec.FindFirst() then
                        SenShipToCountryRegion := CountryRegionRec.Name;
                end;


                if ("Purchase Header"."Language Code" = '') or ("Purchase Header"."Language Code" = 'DEU') or ("Purchase Header"."Language Code" = 'DES') then begin
                    QuoteNo_Lbl := 'Unsere Anfrage';
                    ShipmentDate_Lbl := 'Lieferdatum';
                    Your_Reference_Lbl := 'Ihre Referenz';
                    Purchaser_Code_Lbl := 'Unsere Referenz';
                    SenBelegdatum := 'Belegdatum';
                    SenLieferbedingung := 'Lieferbedingung';
                    SenZahlungsbedingung := 'Zahlungsbedingung';
                    SenTitle := 'Bestellung';
                    SenKontoNr := 'Kontonr.';
                    SenMWSTNr := 'MWST Nr.';
                    SenBeschreibung := 'Beschreibung';
                    SenMenge := 'Menge';
                    SenEinheit := 'Einheit';
                    SenEinheitspreis := 'Einheitspreis';
                    LineAmt_Lbl := 'Zeilenbetrag';
                    ItemNo_Lbl := 'Nr.';
                    SenShipToTitle := 'Lieferadresse';
                    SenArtikelRef_Lbl := 'Artikel Ref.';
                    SenGesamtOhneMWST := 'Gesamtbetrag ohne MWST';
                    Einleitung := PurchasesPayablesSetupRec.Einleitungstext;

                    if PaymentTermsRec.Get("Payment Terms Code") then
                        SenPaymentTerms := PaymentTermsRec.Description;
                end
                else begin
                    QuoteNo_Lbl := 'Inquiry';
                    ShipmentDate_Lbl := 'Shipment Date';
                    Your_Reference_Lbl := 'Your Reference';
                    Purchaser_Code_Lbl := 'Our Contact';
                    SenBelegdatum := 'Document Date';
                    SenLieferbedingung := 'Shipment Method';
                    SenZahlungsbedingung := 'Payment Method';
                    SenTitle := 'Purchase Order';
                    SenKontoNr := 'Account No.';
                    SenMWSTNr := 'VAT No.';
                    SenBeschreibung := 'Description';
                    SenMenge := 'Quant.';
                    SenEinheit := 'Unit';
                    SenEinheitspreis := 'Price per Unit';
                    LineAmt_Lbl := 'Line Amount';
                    ItemNo_Lbl := 'No.';
                    SenShipToTitle := 'Ship to address';
                    SenArtikelRef_Lbl := 'Vendor Item No.';
                    SenGesamtOhneMWST := 'Total excl. VAT';
                    Einleitung := PurchasesPayablesSetupRec."Introduction Text";

                    if PaymentTermsRec.Get("Payment Terms Code") then
                        if PaymentTermTranslationRec.FindSet() then
                            repeat
                                if (PaymentTermTranslationRec."Language Code" = 'ENG') then
                                    SenPaymentTerms := PaymentTermTranslationRec.Description;
                            until PaymentTermTranslationRec.Next() = 0;
                end;

                if SalesPersonPurchaserRec.Get("Purchase Header"."Purchaser Code") then begin
                    PurchaserName := SalesPersonPurchaserRec.Name;
                    PurchaserPhoneNo := SalesPersonPurchaserRec."Phone No.";
                    PurchaserEMail := SalesPersonPurchaserRec."E-Mail";
                end;

                if "Ship-to Name" = '' then begin
                    SenShipToName := CompanyInfoRec.Name;
                    SenShipToAddr := CompanyInfoRec.Address;
                    SenShipToCityPostCode := CompanyInfoRec."Post Code" + ' ' + CompanyInfoRec.City;
                end
                else begin
                    SenShipToName := "Ship-to Name";
                    SenShipToAddr := "Ship-to Address";
                    SenShipToCityPostCode := "Ship-to Post Code" + ' ' + "Ship-to City";
                end;

                if "Requested Receipt Date" <> 0D then
                    ShipmentDate := Format("Requested Receipt Date", 0, '<Closing><Day>. <Month Text> <Year4>');




            end;
        }
        add("Purchase Line")
        {
            column(LineAmt_Lbl; LineAmt_Lbl)
            { }
            column(ItemNo_Lbl; ItemNo_Lbl)
            { }
            column(SenArtikel; "Vendor Item No.")
            { }
            column(SenUnit_Cost; SenUnitCost)
            { }
        }
        modify("Purchase Line")
        {
            trigger OnBeforeAfterGetRecord()
            var
                CustomerRec: Record Customer;
            begin
                if "Direct Unit Cost" = 0 then
                    SenUnitCost := ''
                else
                    SenUnitCost := Format("Direct Unit Cost");

                // if ("Purchase Header"."Language Code" = '') or ("Purchase Header"."Language Code" = 'DEU') or ("Purchase Header"."Language Code" = 'DES') then
                //     SenGesamtOhneMWST := 'Gesamtbetrag ohne MWST'
                // else
                //     SenGesamtOhneMWST := 'Total excl. VAT';
            end;
        }
        addafter("Purchase Line")
        {
            dataitem(SupplierRefs; ReportSupplierWrapperTable)
            {
                column(SupplierRef; SupplierRef)
                { }

                trigger OnPreDataItem()
                var
                    SupplierWrapperRec: Record ReportSupplierWrapperTable;
                    PurchaseItemRec: Record "Purchase Line";
                begin
                    // SupplierRefs.DeleteAll();
                    // SupplierRefs.SupplierRef := "Purchase Line".
                end;
            }
        }
    }


    var
        ShipmentDate_Lbl: Text;
        QuoteNo_Lbl: Text;
        PurchaserName: Text;
        PurchaserPhoneNo: Text;
        PurchaserEMail: Text;
        Purchaser_Code_Lbl: Text;
        Your_Reference_Lbl: Text;
        LineAmt_Lbl: Text;
        ItemNo_Lbl: Text;
        ShipmentDate: Text;
        PurchasesPayablesSetupRec: Record "Purchases & Payables Setup";
        SenShipToName: Text;
        SenShipToAddr: Text;
        SenShipToCityPostCode: Text;
        SenBelegdatum: Text;
        SenLieferbedingung: Text;
        SenZahlungsbedingung: Text;
        SenTitle: Text;
        SenKontoNr: Text;
        SenMWSTNr: Text;
        SenBeschreibung: Text;
        SenMenge: Text;
        SenEinheit: Text;
        SenEinheitspreis: Text;
        SenGesamtOhneMWST: Text;
        SenMWSTProzent: Text;
        SenPaymentTerms: Text;
        SenShipToTitle: Text;
        PaymentTermsRec: Record "Payment Terms";
        SenArtikelRef_Lbl: Text;
        SenArtikel: Text;
        SenUnitCost: Text;
        Einleitung: Text;
        SenBuyFromCountryRegion: Text;
        SenShipToCountryRegion: Text;
        SenBuyFromVendorName: Text;
        SenBuyFromVendorAddress: Text;
        SenBuyFromVendorAdress2: Text;
        SenBuyFromVendorPLZOrt: Text;
}