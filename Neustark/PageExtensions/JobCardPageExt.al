pageextension 50112 JobCardPageExt extends "Job Card"
{
    layout
    {
        addafter("Project Manager")
        {
            field(Bestellungen; Rec.Bestellungen)
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = 9307;

                trigger OnDrillDown()
                var
                    PurchOrderListRec: Record "Purchase Header";
                begin
                    PurchOrderListRec.SetRange(NewJobNo, Rec."No.");
                    Page.RunModal(9307, PurchOrderListRec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin

    end;
}