tableextension 50102 ItemTableExt extends Item
{
    fields
    {
        field(50100; VendorName; Text[250])
        {
            TableRelation = Vendor."No.";
        }
    }
}