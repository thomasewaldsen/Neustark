codeunit 50102 PurchaseOrderLookupCU
{
    procedure GetBestellungen(No: Code[20])
    var
        PurchaseHeaderRec: Record "Purchase Header";
        PurchaseHeaderArchiveRec: Record "Purchase Header Archive";
        TempPurchaseHeaderRec: Record "Purchase Header" temporary;
    begin
        PurchaseHeaderRec.SetRange(NewJobNo, No);
        if PurchaseHeaderRec.FindSet() then
            repeat
                TempPurchaseHeaderRec.Init();
                TempPurchaseHeaderRec.TransferFields(PurchaseHeaderRec);
                TempPurchaseHeaderRec.Insert(false);
            until PurchaseHeaderRec.Next() = 0;

        PurchaseHeaderArchiveRec.SetRange(JobNo, No);
        if PurchaseHeaderArchiveRec.FindSet() then
            repeat
                // if posted purchase order exists - no purchase rec exists, archived version still exists
                TempPurchaseHeaderRec.SetRange("No.", PurchaseHeaderArchiveRec."No.");
                //TempPurchaseHeaderRec.Get(PurchaseHeaderArchiveRec."No.")
                if not (TempPurchaseHeaderRec.FindSet()) then begin
                    TempPurchaseHeaderRec.Init();
                    TempPurchaseHeaderRec.TransferFields(PurchaseHeaderArchiveRec);
                    TempPurchaseHeaderRec.Insert(false);
                end;
            until PurchaseHeaderArchiveRec.Next() = 0;
        Commit();

        TempPurchaseHeaderRec.SetRange("No.");
        TempPurchaseHeaderRec.SetRange(NewJobNo, No);
        Page.RunModal(9307, TempPurchaseHeaderRec);
    end;

    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;
}