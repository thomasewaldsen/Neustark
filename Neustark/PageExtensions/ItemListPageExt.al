pageextension 50106 ItemListPageExt extends "Item List"
{
    layout
    {
        addafter(Description)
        {
            field(VendorName; Rec.VendorName)
            {
                ApplicationArea = All;
                Caption = 'Kred.-Name';
            }
        }
    }
}