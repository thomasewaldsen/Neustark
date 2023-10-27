pageextension 50103 PostedPurchaseInvoicePageExt extends "Posted Purchase Invoice"
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