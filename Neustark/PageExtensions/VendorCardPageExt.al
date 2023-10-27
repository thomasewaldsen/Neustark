pageextension 50117 VendorCardPageExt extends "Vendor Card"
{
    layout
    {
        addafter("No.")
        {
            field(SwsEmployeeNo; Rec.SwsEmployeeNo)
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        modify("Name 2")
        {
            ApplicationArea = All;
            Visible = true;
        }
        moveafter("Name"; "Name 2")
        moveafter("Name 2"; "Search Name")
    }

    actions
    {
        addafter(PayVendor)
        {
            action(DEBUG)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    myInt: Integer;
                begin
                    Rec."Manager No. ASER" := '1111';
                end;
            }
        }
    }

    //     trigger OnDeleteRecord(): Boolean
    //     var
    //         ItemVendor: Record "Item Vendor";
    //         PurchPrepmtPct: Record "Purchase Prepayment %";
    //         CustomReportSelection: Record "Custom Report Selection";
    // #if not CLEAN22
    //         IntrastatSetup: Record "Intrastat Setup";
    // #endif
    //         ItemReference: Record "Item Reference";
    //         VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";

    //         ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //         MoveEntries: Codeunit MoveEntries;
    //         CommentLine: Record "Comment Line";
    //         VendBankAcc: Record "Vendor Bank Account";
    //         OrderAddr: Record "Order Address";
    //         UpdateContFromVend: Codeunit "VendCont-Update";
    //         DimMgt: Codeunit DimensionManagement;
    //         CalendarManagement: Codeunit "Calendar Management";
    //         CustomizedCalendarChange: Record "Customized Calendar Change";

    //         isDelete: Boolean;
    //         SwsEmployeeRec: Record "SwS Employee";
    //     begin
    //         if Dialog.Confirm('Der Kreditor ist noch mit SwissSalary Personal %1 verbunden. Soll Kreditor wirklich gelöscht werden?', false, Rec.SwsEmployeeNo) then begin

    //             // search for sws employee and delete link to vendor
    //             if SwsEmployeeRec.Get(Rec.SwsEmployeeNo) then begin
    //                 SwsEmployeeRec.VendorNo := '';
    //                 SwsEmployeeRec.Modify();
    //             end;

    //             ApprovalsMgmt.OnCancelVendorApprovalRequest(Rec);

    //             MoveEntries.MoveVendorEntries(Rec);

    //             CommentLine.SetRange("Table Name", CommentLine."Table Name"::Vendor);
    //             CommentLine.SetRange("No.", Rec."No.");
    //             if not CommentLine.IsEmpty() then
    //                 CommentLine.DeleteAll();

    //             VendBankAcc.SetRange("Vendor No.", Rec."No.");
    //             if not VendBankAcc.IsEmpty() then
    //                 VendBankAcc.DeleteAll();

    //             OrderAddr.SetRange("Vendor No.", Rec."No.");
    //             if not OrderAddr.IsEmpty() then
    //                 OrderAddr.DeleteAll();

    //             CheckOutstandingPurchaseDocuments();

    //             ItemReference.SetCurrentKey("Reference Type", "Reference Type No.");
    //             ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
    //             ItemReference.SetRange("Reference Type No.", Rec."No.");
    //             ItemReference.DeleteAll();

    //             UpdateContFromVend.OnDelete(Rec);

    //             DimMgt.DeleteDefaultDim(DATABASE::Vendor, Rec."No.");

    //             ItemVendor.SetRange("Vendor No.", Rec."No.");
    //             if not ItemVendor.IsEmpty() then
    //                 ItemVendor.DeleteAll(true);

    //             CustomReportSelection.SetRange("Source Type", DATABASE::Vendor);
    //             CustomReportSelection.SetRange("Source No.", Rec."No.");
    //             if not CustomReportSelection.IsEmpty() then
    //                 CustomReportSelection.DeleteAll();

    //             PurchPrepmtPct.SetCurrentKey("Vendor No.");
    //             PurchPrepmtPct.SetRange("Vendor No.", Rec."No.");
    //             if not PurchPrepmtPct.IsEmpty() then
    //                 PurchPrepmtPct.DeleteAll(true);

    //             VATRegistrationLogMgt.DeleteVendorLog(Rec);
    // #if not CLEAN22
    //             IntrastatSetup.CheckDeleteIntrastatContact(IntrastatSetup."Intrastat Contact Type"::Vendor, Rec."No.");
    // #endif
    //             CalendarManagement.DeleteCustomizedBaseCalendarData(CustomizedCalendarChange."Source Type"::Vendor, Rec."No.");
    //         end;

    //         exit;
    //     end;

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
        PurchOrderLine.SetRange("Pay-to Vendor No.", Rec."No.");
        if PurchOrderLine.FindFirst() then
            Error(
              Text000,
              Rec.TableCaption, Rec."No.",
              PurchOrderLine."Document Type");

        PurchOrderLine.SetRange("Pay-to Vendor No.");
        PurchOrderLine.SetRange("Buy-from Vendor No.", Rec."No.");
        if not PurchOrderLine.IsEmpty() then
            Error(
              Text000,
              Rec.TableCaption, Rec."No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckOutstandingPurchaseDocuments(Vendor: Record Vendor; var IsHandled: Boolean)
    begin
    end;
}