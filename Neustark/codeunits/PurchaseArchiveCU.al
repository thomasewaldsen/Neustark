codeunit 50101 PurchaseArchiveCU
{
    procedure RestorePurchaseDocument(var PurchaseHeaderArchive: Record "Purchase Header Archive")
    var
        SalesHeader: Record "Sales Header";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ReservEntry: Record "Reservation Entry";
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmRequired: Boolean;
        RestoreDocument: Boolean;
        OldOpportunityNo: Code[20];
        IsHandled: Boolean;
        DoCheck, SkipDeletingLinks : Boolean;

        PurchaseHeaderRec: Record "Purchase Header";
        PurchInvHeaderRec: Record "Purch. Inv. Header";
        ItemChargeAssgntPurchaseRec: Record "Item Charge Assignment (Purch)";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ReleasePurchaseDoc: Codeunit "Release Purchase Document";
    begin
        // OnBeforeRestoreSalesDocument(SalesHeaderArchive, IsHandled);
        if IsHandled then
            exit;

        if not PurchaseHeaderRec.Get(PurchaseHeaderArchive."Document Type", PurchaseHeaderArchive."No.") then begin
            PurchaseHeaderRec.Init();
            PurchaseHeaderRec."No." := PurchaseHeaderArchive."No.";
            PurchaseHeaderRec."Document Type" := PurchaseHeaderArchive."Document Type";
            PurchaseHeaderRec.Status := PurchaseHeaderRec.Status::Open;
            PurchaseHeaderRec.SetHideValidationDialog(true)
        end
        else
            Error(Text010, PurchaseHeaderArchive."No.");

        PurchaseHeaderRec.TestField(Status, PurchaseHeaderRec.Status::Open);

        DoCheck := true;
        // OnBeforeCheckIfDocumentIsPartiallyPosted(SalesHeaderArchive, DoCheck);

        if (PurchaseHeaderRec."Document Type" = PurchaseHeaderRec."Document Type"::Order) and DoCheck then begin
            // SalesShptHeader.Reset();
            // SalesShptHeader.SetCurrentKey("Order No.");
            // SalesShptHeader.SetRange("Order No.", SalesHeader."No.");
            // if not SalesShptHeader.IsEmpty() then
            //     Error(Text005, SalesHeader."Document Type", SalesHeader."No.");
            PurchInvHeaderRec.Reset();
            PurchInvHeaderRec.SetCurrentKey("Order No.");
            PurchInvHeaderRec.SetRange("Order No.", PurchaseHeaderRec."No.");
            // if not PurchInvHeaderRec.IsEmpty() then
            //     Error(Text005, PurchaseHeaderRec."Document Type", PurchaseHeaderRec."No.");
        end;

        ConfirmRequired := false;
        ReservEntry.Reset();
        ReservEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype");
        ReservEntry.SetRange("Source ID", PurchaseHeaderRec."No.");
        ReservEntry.SetRange("Source Type", DATABASE::"Sales Line"); // TODO. Change to Purchase Line
        ReservEntry.SetRange("Source Subtype", PurchaseHeaderRec."Document Type");
        if ReservEntry.FindFirst() then
            ConfirmRequired := true;

        ItemChargeAssgntPurchaseRec.Reset();
        ItemChargeAssgntPurchaseRec.SetRange("Document Type", PurchaseHeaderRec."Document Type");
        ItemChargeAssgntPurchaseRec.SetRange("Document No.", PurchaseHeaderRec."No.");
        if ItemChargeAssgntPurchaseRec.FindFirst() then
            ConfirmRequired := true;

        RestoreDocument := false;
        if ConfirmRequired then begin
            if ConfirmManagement.GetResponseOrDefault(
                 StrSubstNo(
                   Text006, ReservEntry.TableCaption(), ItemChargeAssgntPurchaseRec.TableCaption(), Text008), true)
            then
                RestoreDocument := true;
        end else
            if ConfirmManagement.GetResponseOrDefault(
                 StrSubstNo(
                   Text002, PurchaseHeaderArchive."Document Type",
                   PurchaseHeaderArchive."No.", PurchaseHeaderArchive."Version No."), true)
            then
                RestoreDocument := true;
        if RestoreDocument then begin
            // PurchaseHeaderRec.TestField("Doc. No. Occurrence", PurchaseHeaderArchive."Doc. No. Occurrence");
            // PurchaseHeaderArchive.CalcFields("Work Description");
            // if PurchaseHeaderRec."Opportunity No." <> '' then begin
            //     OldOpportunityNo := PurchaseHeaderRec."Opportunity No.";
            //     PurchaseHeaderRec."Opportunity No." := '';
            //     // TODO: Check if necessary
            // end;
            SkipDeletingLinks := false;
            // OnRestoreDocumentOnBeforeDeleteSalesHeader(SalesHeader, SkipDeletingLinks);
            if not SkipDeletingLinks then
                PurchaseHeaderRec.DeleteLinks();

            // PurchaseHeaderRec.Delete(true);

            // OnRestoreDocumentOnAfterDeleteSalesHeader(SalesHeader);

            // PurchaseHeaderRec.Init();
            // PurchaseHeaderRec.SetHideValidationDialog(true);
            // PurchaseHeaderRec."Document Type" := PurchaseHeaderArchive."Document Type";
            // PurchaseHeaderRec."No." := PurchaseHeaderArchive."No.";

            // OnBeforeSalesHeaderInsert(SalesHeader, SalesHeaderArchive);
            PurchaseHeaderRec.Insert(true);
            // OnRestoreSalesDocumentOnAfterSalesHeaderInsert(SalesHeader, PurchaseHeaderArchive);
            PurchaseHeaderRec.TransferFields(PurchaseHeaderArchive);
            PurchaseHeaderRec.Status := PurchaseHeaderRec.Status::Open;
            // TODO: Change to buy from contact
            if PurchaseHeaderArchive."Buy-from Contact No." <> '' then
                PurchaseHeaderRec.Validate("Buy-from Contact No.", PurchaseHeaderArchive."Buy-from Contact No.")
            else
                PurchaseHeaderRec.Validate("Sell-to Customer No.", PurchaseHeaderArchive."Sell-to Customer No.");
            // if PurchaseHeaderArchive."Bill-to Contact No." <> '' then
            //     PurchaseHeaderRec.Validate("Bill-to Contact No.", PurchaseHeaderArchive."Bill-to Contact No.")
            // else
            //     PurchaseHeaderRec.Validate("Bill-to Customer No.", PurchaseHeaderArchive."Bill-to Customer No.");
            PurchaseHeaderRec.Validate("Purchaser Code", PurchaseHeaderArchive."Purchaser Code");
            PurchaseHeaderRec.Validate("Payment Terms Code", PurchaseHeaderArchive."Payment Terms Code");
            PurchaseHeaderRec.Validate("Payment Discount %", PurchaseHeaderArchive."Payment Discount %");
            PurchaseHeaderRec."Shortcut Dimension 1 Code" := PurchaseHeaderArchive."Shortcut Dimension 1 Code";
            PurchaseHeaderRec."Shortcut Dimension 2 Code" := PurchaseHeaderArchive."Shortcut Dimension 2 Code";
            PurchaseHeaderRec."Dimension Set ID" := PurchaseHeaderArchive."Dimension Set ID";
            RecordLinkManagement.CopyLinks(PurchaseHeaderArchive, PurchaseHeaderRec);
            SalesHeader.LinkSalesDocWithOpportunity(OldOpportunityNo);
            // OnAfterTransferFromArchToSalesHeader(SalesHeader, PurchaseHeaderArchive);
            PurchaseHeaderRec.Modify(true);
            // ResetQuoteStatus(SalesHeader);
            RestoreSalesLines(PurchaseHeaderArchive, PurchaseHeaderRec);
            PurchaseHeaderRec.Status := PurchaseHeaderRec.Status::Released;
            ReleasePurchaseDoc.Reopen(PurchaseHeaderRec);
            // OnAfterRestoreSalesDocument(PurchaseHeaderRec, PurchaseHeaderArchive);

            Message(Text003, PurchaseHeaderRec."Document Type", PurchaseHeaderRec."No.");
        end;
    end;

    local procedure RestoreSalesLines(var PurchaseHeaderArchive: Record "Purchase Header Archive"; PurchaseHeader: Record "Purchase Header")
    var
        // SalesLine: Record "Sales Line";
        // SalesLineArchive: Record "Sales Line Archive";
        ShouldValidateQuantity: Boolean;
        PurchaseLineArchive: Record "Purchase Line Archive";
        PurchaseLine: Record "Purchase Line";
    begin
        RestorePurchaseLineComments(PurchaseHeaderArchive, PurchaseHeader);

        PurchaseLineArchive.SetRange("Document Type", PurchaseHeaderArchive."Document Type");
        PurchaseLineArchive.SetRange("Document No.", PurchaseHeaderArchive."No.");
        PurchaseLineArchive.SetRange("Doc. No. Occurrence", PurchaseHeaderArchive."Doc. No. Occurrence");
        PurchaseLineArchive.SetRange("Version No.", PurchaseHeaderArchive."Version No.");
        // OnRestoreSalesLinesOnAfterSalesLineArchiveSetFilters(SalesLineArchive, SalesHeaderArchive, SalesHeader);
        if PurchaseLineArchive.FindSet() then
            repeat
                with PurchaseLine do begin
                    Init();
                    TransferFields(PurchaseLineArchive);
                    // OnRestoreSalesLinesOnBeforeSalesLineInsert(SalesLine, SalesLineArchive);
                    Insert(true);
                    // OnRestoreSalesLinesOnAfterSalesLineInsert(SalesLine, SalesLineArchive);
                    if Type <> Type::" " then begin
                        Validate("No.");
                        if PurchaseLineArchive."Variant Code" <> '' then
                            Validate("Variant Code", PurchaseLineArchive."Variant Code");
                        if PurchaseLineArchive."Unit of Measure Code" <> '' then
                            Validate("Unit of Measure Code", PurchaseLineArchive."Unit of Measure Code");
                        Validate("Location Code", PurchaseLineArchive."Location Code");
                        ShouldValidateQuantity := Quantity <> 0;
                        // OnRestoreSalesLinesOnAfterCalcShouldValidateQuantity(SalesLine, SalesLineArchive, ShouldValidateQuantity);
                        if ShouldValidateQuantity then
                            Validate(Quantity, PurchaseLineArchive.Quantity);
                        // OnRestoreSalesLinesOnAfterValidateQuantity(SalesLine, SalesLineArchive);
                        Validate("Unit Cost", PurchaseLineArchive."Unit Cost");
                        Validate("Unit Cost (LCY)", PurchaseLineArchive."Unit Cost (LCY)");
                        Validate("Line Discount %", PurchaseLineArchive."Line Discount %");
                        // Validate("Quote Variant", PurchaseLineArchive."Quote Variant");
                        if PurchaseLineArchive."Inv. Discount Amount" <> 0 then
                            Validate("Inv. Discount Amount", PurchaseLineArchive."Inv. Discount Amount");
                        if Amount <> PurchaseLineArchive.Amount then
                            Validate(Amount, PurchaseLineArchive.Amount);
                        Validate(Description, PurchaseLineArchive.Description);
                    end;
                    "Shortcut Dimension 1 Code" := PurchaseLineArchive."Shortcut Dimension 1 Code";
                    "Shortcut Dimension 2 Code" := PurchaseLineArchive."Shortcut Dimension 2 Code";
                    "Dimension Set ID" := PurchaseLineArchive."Dimension Set ID";
                    "Deferral Code" := PurchaseLineArchive."Deferral Code";
                    RestoreDeferrals(
                        "Deferral Document Type"::Sales.AsInteger(),
                        PurchaseLineArchive."Document Type".AsInteger(), PurchaseLineArchive."Document No.", PurchaseLineArchive."Line No.",
                        PurchaseHeaderArchive."Doc. No. Occurrence", PurchaseHeaderArchive."Version No.");
                    RecordLinkManagement.CopyLinks(PurchaseLineArchive, PurchaseLine);
                    // OnAfterTransferFromArchToSalesLine(PurchaseLine, PurchaseLineArchive);
                    Modify(true);
                end;
            // OnAfterRestoreSalesLine(SalesHeader, SalesLine, SalesHeaderArchive, SalesLineArchive);
            until PurchaseLineArchive.Next() = 0;

        // OnAfterRestoreSalesLines(SalesHeader, SalesLine, SalesHeaderArchive, SalesLineArchive);
    end;

    local procedure RestorePurchaseLineComments(PurchaseHeaderArchive: Record "Purchase Header Archive"; PurchaseHeader: Record "Purchase Header")
    var
        SalesCommentLineArchive: Record "Sales Comment Line Archive";
        SalesCommentLine: Record "Sales Comment Line";
        NextLine: Integer;
        PurchaseCommentLine: Record "Purch. Comment Line";
        PurchaseCommentLineArchive: Record "Purch. Comment Line Archive";
    begin
        PurchaseCommentLineArchive.SetRange("Document Type", PurchaseHeaderArchive."Document Type");
        PurchaseCommentLineArchive.SetRange("No.", PurchaseHeaderArchive."No.");
        PurchaseCommentLineArchive.SetRange("Doc. No. Occurrence", PurchaseHeaderArchive."Doc. No. Occurrence");
        PurchaseCommentLineArchive.SetRange("Version No.", PurchaseHeaderArchive."Version No.");
        if PurchaseCommentLineArchive.FindSet() then
            repeat
                PurchaseCommentLine.Init();
                PurchaseCommentLine.TransferFields(PurchaseCommentLineArchive);
                PurchaseCommentLine.Insert();
            until PurchaseCommentLineArchive.Next() = 0;

        PurchaseCommentLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseCommentLine.SetRange("No.", PurchaseHeader."No.");
        PurchaseCommentLine.SetRange("Document Line No.", 0);
        if PurchaseCommentLine.FindLast() then
            NextLine := PurchaseCommentLine."Line No.";
        NextLine += 10000;
        PurchaseCommentLine.Init();
        PurchaseCommentLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseCommentLine."No." := PurchaseHeader."No.";
        PurchaseCommentLine."Document Line No." := 0;
        PurchaseCommentLine."Line No." := NextLine;
        PurchaseCommentLine.Date := WorkDate();
        PurchaseCommentLine.Comment := StrSubstNo(Text004, Format(PurchaseHeaderArchive."Version No."));
        // OnRestoreSalesLineCommentsOnBeforeInsertSalesCommentLine(SalesCommentLine);
        PurchaseCommentLine.Insert();
    end;

    local procedure RestoreDeferrals(DeferralDocType: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; DocNoOccurrence: Integer; VersionNo: Integer)
    var
        DeferralHeaderArchive: Record "Deferral Header Archive";
        DeferralLineArchive: Record "Deferral Line Archive";
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
    begin
        if DeferralHeaderArchive.Get(DeferralDocType, DocType, DocNo, DocNoOccurrence, VersionNo, LineNo) then begin
            // OnRestoreDeferralsOnAfterGetDeferralHeaderArchive(DeferralHeaderArchive, DeferralHeader);
            // Updates the header if is exists already and removes all the lines
            DeferralUtilities.SetDeferralRecords(DeferralHeader,
              DeferralDocType, '', '',
              DocType, DocNo, LineNo,
              DeferralHeaderArchive."Calc. Method",
              DeferralHeaderArchive."No. of Periods",
              DeferralHeaderArchive."Amount to Defer",
              DeferralHeaderArchive."Start Date",
              DeferralHeaderArchive."Deferral Code",
              DeferralHeaderArchive."Schedule Description",
              DeferralHeaderArchive."Initial Amount to Defer",
              true,
              DeferralHeaderArchive."Currency Code");

            // Add lines as exist in the archives
            DeferralLineArchive.SetRange("Deferral Doc. Type", DeferralDocType);
            DeferralLineArchive.SetRange("Document Type", DocType);
            DeferralLineArchive.SetRange("Document No.", DocNo);
            DeferralLineArchive.SetRange("Doc. No. Occurrence", DocNoOccurrence);
            DeferralLineArchive.SetRange("Version No.", VersionNo);
            DeferralLineArchive.SetRange("Line No.", LineNo);
            if DeferralLineArchive.FindSet() then
                repeat
                    DeferralLine.Init();
                    DeferralLine.TransferFields(DeferralLineArchive);
                    DeferralLine.Insert();
                until DeferralLineArchive.Next() = 0;
        end else
            // Removes any lines that may have been defaulted
            DeferralUtilities.RemoveOrSetDeferralSchedule('', DeferralDocType, '', '', DocType, DocNo, LineNo, 0, 0D, '', '', true);
    end;

    // [Scope('OnPrem')]
    // procedure ResetQuoteStatus(SalesHeader: Record "Sales Header")
    // var
    //     ArchivedSalesHeader: Record "Sales Header Archive";
    // begin
    //     ArchivedSalesHeader.SetRange("Document Type", SalesHeader."Document Type");
    //     ArchivedSalesHeader.SetRange("No.", SalesHeader."No.");
    //     ArchivedSalesHeader.ModifyAll("Quote Status", ArchivedSalesHeader."Quote Status"::" ");
    // end;

    local procedure CreateNewPurchaseInvoice()
    var
    begin
    end;

    var
        RecordLinkManagement: Codeunit "Record Link Management";
        DeferralUtilities: Codeunit "Deferral Utilities";
        Text001: Label 'Document %1 has been archived.';
        Text002: Label 'Do you want to Restore %1 %2 Version %3?';
        Text003: Label '%1 %2 has been restored.';
        Text004: Label 'Document restored from Version %1.';
        Text005: Label '%1 %2 has been partly posted.\Restore not possible.';
        Text006: Label 'Entries exist for on or more of the following:\  - %1\  - %2\  - %3.\Restoration of document will delete these entries.\Continue with restore?';
        Text007: Label 'Archive %1 no.: %2?';
        Text008: Label 'Item Tracking Line';
        Text009: Label 'Unposted %1 %2 does not exist anymore.\It is not possible to restore the %1.';
        Text010: Label 'Another Version of %1 Purchase Order has already been restored';
}