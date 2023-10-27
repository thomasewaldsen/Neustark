pageextension 50107 GLLedgerEntriesPageExt extends "General Ledger Entries"
{
    trigger OnModifyRecord(): Boolean
    var
        CostEntriesRec: Record "Cost Entry";
    begin
        CostEntriesRec.SetRange("G/L Entry No.", Rec."Entry No.");
        if CostEntriesRec.FindSet() then begin
            CostEntriesRec."Cost Center Code" := Rec."Global Dimension 1 Code";
            CostEntriesRec."Cost Object Code" := Rec."Global Dimension 2 Code";
        end;
    end;
    // actions
    // {
    //     modify(ValidateCorrection)
    //     {
    //         trigger OnBeforeAction()
    //         var
    //             CostEntriesRec: Record "Cost Entry";

    //         begin
    //             Message('close');
    //             CostEntriesRec.SetRange("G/L Entry No.", Rec."Entry No.");
    //             if CostEntriesRec.FindSet() then begin

    //             end;
    //         end;
    //     }
    // }
}