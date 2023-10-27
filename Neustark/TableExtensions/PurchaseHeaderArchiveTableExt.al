tableextension 50107 PurchaseHeaderArchiveTableExt extends "Purchase Header Archive"
{
    fields
    {
        field(50101; JobNo; Code[20])
        {
            TableRelation = Job."No.";
        }
        field(50102; SenQty; Decimal)
        {
            InitValue = 1;
        }
    }
}