pageextension 50105 ItemCardPageExt extends "Item Card"
{
    layout
    {
        addafter(Description)
        {
            field(MainSpecs; Rec."Description 2")
            {
                ApplicationArea = All;
                Caption = 'MAIN SPECS';
            }
        }
        addafter("Vendor Item No.")
        {
            field(VendorName; Rec.VendorName)
            {
                ApplicationArea = All;
                Caption = 'Kred.-Name';

                trigger OnValidate()
                var
                    Vendor: Record Vendor;
                begin
                    if Rec.VendorName <> '' then begin
                        Vendor.SetRange("No.", Rec.VendorName);
                        if Vendor.FindSet() then
                            Rec.VendorName := Vendor.Name;
                    end;
                end;
            }
        }
    }
}