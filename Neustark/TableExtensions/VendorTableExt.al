tableextension 50109 VendorTableExt extends Vendor
{
    fields
    {
        field(50100; SwsEmployeeNo; Code[10])
        { }
    }

    trigger OnBeforeDelete()
    var
        ItemVendor: Record "Item Vendor";
        PurchPrepmtPct: Record "Purchase Prepayment %";
        CustomReportSelection: Record "Custom Report Selection";
#if not CLEAN22
        IntrastatSetup: Record "Intrastat Setup";
#endif
        ItemReference: Record "Item Reference";
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";

        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        MoveEntries: Codeunit MoveEntries;
        CommentLine: Record "Comment Line";
        VendBankAcc: Record "Vendor Bank Account";
        OrderAddr: Record "Order Address";
        UpdateContFromVend: Codeunit "VendCont-Update";
        DimMgt: Codeunit DimensionManagement;
        CalendarManagement: Codeunit "Calendar Management";
        CustomizedCalendarChange: Record "Customized Calendar Change";

        isDelete: Boolean;
        SwsEmployeeRec: Record "SwS Employee";
    begin
        if SwsEmployeeRec.Get(SwsEmployeeNo) then
            if not Dialog.Confirm('Der Kreditor ist noch mit SwissSalary Personal %1 verbunden. Soll Kreditor wirklich gelöscht werden?', false, SwsEmployeeNo) then
                ERROR('');

        // search for sws employee and delete link to vendor
        if SwsEmployeeRec.Get(SwsEmployeeNo) then begin
            SwsEmployeeRec.VendorNo := '';
            SwsEmployeeRec.Modify();
        end;

        ApprovalsMgmt.OnCancelVendorApprovalRequest(Rec);

        MoveEntries.MoveVendorEntries(Rec);

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::Vendor);
        CommentLine.SetRange("No.", "No.");
        if not CommentLine.IsEmpty() then
            CommentLine.DeleteAll();

        VendBankAcc.SetRange("Vendor No.", "No.");
        if not VendBankAcc.IsEmpty() then
            VendBankAcc.DeleteAll();

        OrderAddr.SetRange("Vendor No.", "No.");
        if not OrderAddr.IsEmpty() then
            OrderAddr.DeleteAll();

        CheckOutstandingPurchaseDocuments();

        ItemReference.SetCurrentKey("Reference Type", "Reference Type No.");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", Rec."No.");
        ItemReference.DeleteAll();

        UpdateContFromVend.OnDelete(Rec);

        DimMgt.DeleteDefaultDim(DATABASE::Vendor, "No.");

        ItemVendor.SetRange("Vendor No.", "No.");
        if not ItemVendor.IsEmpty() then
            ItemVendor.DeleteAll(true);

        CustomReportSelection.SetRange("Source Type", DATABASE::Vendor);
        CustomReportSelection.SetRange("Source No.", "No.");
        if not CustomReportSelection.IsEmpty() then
            CustomReportSelection.DeleteAll();

        PurchPrepmtPct.SetCurrentKey("Vendor No.");
        PurchPrepmtPct.SetRange("Vendor No.", "No.");
        if not PurchPrepmtPct.IsEmpty() then
            PurchPrepmtPct.DeleteAll(true);

        VATRegistrationLogMgt.DeleteVendorLog(Rec);
#if not CLEAN22
        IntrastatSetup.CheckDeleteIntrastatContact(IntrastatSetup."Intrastat Contact Type"::Vendor, "No.");
#endif
        CalendarManagement.DeleteCustomizedBaseCalendarData(CustomizedCalendarChange."Source Type"::Vendor, "No.");
    end;

    local procedure CheckOutstandingPurchaseDocuments()
    var
        PurchOrderLine: Record "Purchase Line";
        IsHandled: Boolean;
        Text000: Label 'You cannot delete %1 %2 because there is at least one outstanding Purchase %3 for this vendor.';
    begin
        IsHandled := false;
        OnBeforeCheckOutstandingPurchaseDocuments(Rec, IsHandled);
        if IsHandled then
            exit;

        PurchOrderLine.SetCurrentKey("Document Type", "Pay-to Vendor No.");
        PurchOrderLine.SetRange("Pay-to Vendor No.", "No.");
        if PurchOrderLine.FindFirst() then
            Error(
              Text000,
              TableCaption, "No.",
              PurchOrderLine."Document Type");

        PurchOrderLine.SetRange("Pay-to Vendor No.");
        PurchOrderLine.SetRange("Buy-from Vendor No.", "No.");
        if not PurchOrderLine.IsEmpty() then
            Error(
              Text000,
              TableCaption, "No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckOutstandingPurchaseDocuments(Vendor: Record Vendor; var IsHandled: Boolean)
    begin
    end;
}