pageextension 50110 PurchasesPayablesSetupPageExt extends "Purchases & Payables Setup"
{
    layout
    {
        addafter(General)
        {
            group(Neustark)
            {
                Visible = true;
                field(Einleitungstext; Rec.Einleitungstext)
                {
                    ApplicationArea = All;
                    Visible = true;
                    MultiLine = true;
                }
                field("Introduction Text"; Rec."Introduction Text")
                {
                    ApplicationArea = All;
                    Visible = true;
                    MultiLine = true;
                }
            }
        }
    }

    var
        myInt: Integer;
}