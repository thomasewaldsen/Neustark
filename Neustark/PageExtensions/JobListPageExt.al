pageextension 50114 JobListPageExt extends "Job List"
{
    layout
    {
        // addafter(Description)
        // {
        //     field(Bestellungen; Rec.Bestellungen)
        //     {
        //         ApplicationArea = All;
        //         DrillDown = true;
        //         DrillDownPageId = 9307;

        //         trigger OnDrillDown()
        //         var
        //             PurchOrderListRec: Record "Purchase Header";
        //         begin
        //             PurchOrderListRec.SetRange(JobNo, Rec."No.");
        //             Page.RunModal(9307, PurchOrderListRec);
        //         end;
        //     }
        // }
        addafter(Description)
        {
            field(BestellungenMarkup; counter)
            {
                ApplicationArea = All;
                Caption = 'Bestellungen';

                trigger OnDrillDown()
                var
                    PurchaseOrderLookupCU: codeunit PurchaseOrderLookupCU;
                begin
                    PurchaseOrderLookupCU.GetBestellungen(Rec."No.");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        PurchaseHeaderRec: Record "Purchase Header";
        PurchaseArchiveHeaderRec: Record "Purchase Header Archive";
    begin
        counter := 0;

        PurchaseHeaderRec.SetRange(NewJobNo, Rec."No.");
        if PurchaseHeaderRec.FindSet() then
            repeat
                counter += 1;
            until PurchaseHeaderRec.Next() = 0;

        PurchaseArchiveHeaderRec.SetRange(JobNo, Rec."No.");
        if PurchaseArchiveHeaderRec.FindSet() then
            repeat
                // if not purchaseheader.no = purchaseheaderarchive.no
                PurchaseHeaderRec.SetRange("No.", PurchaseArchiveHeaderRec."No.");
                if not PurchaseHeaderRec.FindSet() then
                    counter += 1;
            until PurchaseArchiveHeaderRec.Next() = 0;

        // if Rec."Job No." <> '' then begin
        //     if PurchaseHeaderRec.Get("Document Type"::Invoice, Rec."Document No.") then
        //         PurchaseHeaderRec.JobNo += Rec."Job No."
        // end;

    end;

    var
        counter: Integer;

}