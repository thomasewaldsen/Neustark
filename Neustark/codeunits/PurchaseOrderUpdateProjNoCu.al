codeunit 50103 PurchaseOrderUpdateProjectNo
{

    trigger OnRun()
    var
        PurchaseHeaderRec: Record "Purchase Header";
        PurchaseLineRec: Record "Purchase Line";
        tmpJobNoString: Text;
        jobNos: List of [Text];
        i: Integer;
        tmp1: Text;
        tmp2: Text;
        n: Integer;
        PurchaseOrderUpdateProjectNosCU: Codeunit PurchaseOrderUpdateProjectNo;
    begin
        if PurchaseHeaderRec.FindSet() then begin
            repeat
                PurchaseLineRec.SetRange("Document No.", PurchaseHeaderRec."No.");
                if PurchaseLineRec.FindSet() then begin
                    repeat
                        if (PurchaseLineRec."Job No." <> '') and not (PurchaseHeaderRec.NewJobNo.Contains(PurchaseLineRec."Job No.")) then
                            if PurchaseHeaderRec.NewJobNo <> '' then
                                PurchaseHeaderRec.NewJobNo += ' | ' + PurchaseLineRec."Job No."
                            else
                                PurchaseHeaderRec.NewJobNo += PurchaseLineRec."Job No."
                    until PurchaseLineRec.Next() = 0;

                    jobNos := PurchaseHeaderRec.NewJobNo.Split('|');

                    // sort
                    for n := 1 to jobNos.Count() - 1 do
                        for i := 1 to jobNos.Count() - 1 do begin
                            tmp1 := jobNos.Get(i);
                            tmp2 := jobNos.Get(i + 1);
                            if tmp1 > tmp2 then begin
                                jobNos.RemoveAt(i);
                                jobNos.Insert(i, tmp2);
                                jobNos.RemoveAt(i + 1);
                                jobNos.Insert(i + 1, tmp1);
                            end;
                        end;

                    PurchaseHeaderRec.NewJobNo := '';
                    for i := 1 to jobNos.Count() do begin
                        if PurchaseHeaderRec.NewJobNo <> '' then
                            PurchaseHeaderRec.NewJobNo += ' | ' + jobNos.Get(i)
                        else
                            PurchaseHeaderRec.NewJobNo += jobNos.Get(i);
                    end;
                end;

                PurchaseHeaderRec.Modify();
            until PurchaseHeaderRec.Next() = 0;
        end;
    end;
}