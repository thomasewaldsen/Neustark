pageextension 50101 PurchaseOrderListPageExt extends "Purchase Order List"
{
    layout
    {
        modify("No.")
        {
            StyleExpr = myExpr;
        }
        modify("Buy-from Vendor No.")
        {
            StyleExpr = myExpr;
        }
        modify("Buy-from Vendor Name")
        {
            StyleExpr = myExpr;
        }

        addafter(Status)
        {
            field(ProcessStatus; Rec.ProcessStatus)
            {
                ApplicationArea = All;
                Caption = 'Prozess-Status';
            }
        }
        addafter("Buy-from Vendor Name")
        {
            field(YourReference; Rec."Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Ihre Referenz';
            }
            field(JobNo; Rec.NewJobNo)
            {
                ApplicationArea = All;
                Caption = 'Projekt Nr.';
            }
        }
        modify("Requested Receipt Date")
        {
            Visible = true;
        }
        moveafter(JobNo; "Requested Receipt Date")
        addafter("Requested Receipt Date")
        {
            field("Promised Receipt Date"; Rec."Promised Receipt Date")
            {
                ApplicationArea = All;
                Caption = 'Zugesagtes Wareneingangsdatum';
            }
        }
    }

    trigger OnOpenPage()
    var
        PurchaseHeaderRec: Record "Purchase Header";
        PurchaseHeaderArchiveRec: Record "Purchase Header Archive";
        TempPurchaseHeaderRec: Record "Purchase Header" temporary;
    begin
        PurchaseHeaderRec.SetRange("No.", Rec."No.");
        if PurchaseHeaderRec.FindSet() then
            repeat
                TempPurchaseHeaderRec.Init();
                TempPurchaseHeaderRec.TransferFields(PurchaseHeaderRec);
            until PurchaseHeaderRec.Next() = 0;
    end;

    trigger OnAfterGetRecord()
    var
        PurchaseArchiveHeaderRec: Record "Purchase Header Archive";
        PurchaseHeaderRec: Record "Purchase Header";
    begin
        PurchaseHeaderRec.SetRange("No.", Rec."No.");
        if not PurchaseHeaderRec.FindSet() then begin
            PurchaseArchiveHeaderRec.SetRange("No.", Rec."No.");
            if PurchaseArchiveHeaderRec.FindSet() then
                myExpr := 'Unfavorable'
            else
                myExpr := 'Standard';
        end
        else
            myExpr := 'Standard';
    end;

    var
        myExpr: Text;
}