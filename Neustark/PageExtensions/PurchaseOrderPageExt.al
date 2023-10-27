pageextension 50100 PurchaseOrderPageExt extends "Purchase Order"
{
    layout
    {
        addafter(Status)
        {
            field(ProcessStatus; Rec.ProcessStatus)
            {
                ApplicationArea = All;
                Caption = 'Prozess-Status';
            }
        }
        moveafter(ProcessStatus; "Your Reference")
        addafter("Your Reference")
        {
            field(JobNo; Rec.NewJobNo)
            {
                ApplicationArea = All;
                Caption = 'Projekt Nr.';
            }
        }
        modify("Quote No.")
        {
            Editable = true;
        }
    }
    actions
    {
        addafter(Post)
        {
            action(SetProjectNo)
            {
                Caption = 'Projekt Nr. aktualisieren';
                ApplicationArea = All;

                trigger OnAction()
                var
                    PurchaseLineRec: Record "Purchase Line";
                    tmpJobNoString: Text;
                    jobNos: List of [Text];
                    i: Integer;
                    tmp1: Text;
                    tmp2: Text;
                    n: Integer;
                    PurchaseOrderUpdateProjectNosCU: Codeunit PurchaseOrderUpdateProjectNo;
                begin
                    PurchaseLineRec.SetRange("Document No.", Rec."No.");
                    if PurchaseLineRec.FindSet() then begin
                        repeat
                            if (PurchaseLineRec."Job No." <> '') and not (Rec.NewJobNo.Contains(PurchaseLineRec."Job No.")) then
                                if rec.NewJobNo <> '' then
                                    Rec.NewJobNo += ' | ' + PurchaseLineRec."Job No."
                                else
                                    Rec.NewJobNo += PurchaseLineRec."Job No."
                        until PurchaseLineRec.Next() = 0;

                        // Rec.JobNo := PurchaseOrderUpdateProjectNosCU.GetProjNos(PurchaseLineRec, Rec.JobNo);

                        jobNos := Rec.NewJobNo.Split('|');

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

                        Rec.NewJobNo := '';
                        for i := 1 to jobNos.Count() do begin
                            if Rec.NewJobNo <> '' then
                                Rec.NewJobNo += ' | ' + jobNos.Get(i)
                            else
                                Rec.NewJobNo += jobNos.Get(i);
                        end;
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        if Rec.SenQty = 0 then begin
            Rec.SenQty := 1;
            Rec.Modify();
        end;
    end;
}