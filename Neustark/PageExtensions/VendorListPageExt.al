pageextension 50118 VendorListPageExt extends "Vendor List"
{
    layout
    {
        modify("Name 2")
        {
            ApplicationArea = All;
            Visible = true;
        }
        moveafter("Name"; "Name 2")
        moveafter("Name 2"; "Search Name")
    }
}