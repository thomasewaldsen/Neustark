pageextension 50111 PurchaseOrderSubformPageExt extends "Purchase Order Subform"
{
    layout
    {
        addbefore(Type)
        {
            field(SenLineNo; Rec.SenLineNo)
            {
                Caption = 'Line No';
                ApplicationArea = All;
            }
        }
        modify("Direct Unit Cost")
        {
            ApplicationArea = All;
            BlankZero = true;
        }
        modify("Line No.")
        {
            ApplicationArea = All;
            Visible = true;
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        PurchaseLineRec: Record "Purchase Line";
    begin
        // get last used no
        PurchaseLineRec.SetRange("Document Type", "Purchase Document Type"::Order);
        PurchaseLineRec.SetRange("Document No.", Rec."Document No.");
        if PurchaseLineRec.FindSet() then
            repeat
                Rec.SenLineNo += 1;
            until PurchaseLineRec.Next() = 0;
        Rec.SenLineNo += 1;
    end;

    trigger OnAfterGetRecord()
    var
        PurchaseLineRec: Record "Purchase Line";
        i: Integer;
    begin
        PurchaseLineRec.SetRange("Document Type", "Purchase Document Type"::Order);
        PurchaseLineRec.SetRange("Document No.", Rec."Document No.");
        if PurchaseLineRec.FindSet() then
            repeat
                i += 1;
                PurchaseLineRec.SenLineNo := i;
                PurchaseLineRec.Modify();
            until PurchaseLineRec.Next() = 0;
    end;
}