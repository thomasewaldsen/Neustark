tableextension 50100 PurchaseHeaderTableExt extends "Purchase Header"
{
    fields
    {
        field(50100; ProcessStatus; Enum ProcessStatusEnum)
        {
        }
        field(50101; JobNo; Code[20])
        {
            // TableRelation = Job."No.";
            ObsoleteState = Removed;
        }
        field(50102; SenQty; Decimal)
        {
            InitValue = 1;
        }
        field(50103; SenLineNo; Integer)
        { }
        field(50104; NewJobNo; Text[2048])
        {
            // TableRelation = Job."No.";
        }

    }

    trigger OnInsert()
    begin
        ProcessStatus := ProcessStatusEnum::"nicht bestellt";
    end;
}