pageextension 50104 PostedPurchInvListPageExt extends "Posted Purchase Invoices"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field(ProcessStatus; Rec.ProcessStatus)
            {
                ApplicationArea = All;
                Caption = 'Prozess-Status';
            }
        }
    }
}