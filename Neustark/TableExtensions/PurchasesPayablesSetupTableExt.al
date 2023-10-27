tableextension 50103 PurchasesPayablesSetupTableExt extends "Purchases & Payables Setup"
{
    fields
    {
        field(50100; Einleitungstext; Text[100])
        {
            // Caption = 'Introduction Text';
            Caption = 'Einleitungstext';
        }
        field(50101; "Introduction Text"; Text[100])
        {
        }
    }

    var
        myInt: Integer;
}