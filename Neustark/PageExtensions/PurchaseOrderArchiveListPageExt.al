pageextension 50115 PurchaseOrderArchiveListExt extends "Purchase Order Archives"
{
    layout
    {
        addafter("Location Code")
        {
            field(JobNo; Rec.JobNo)
            {
                ApplicationArea = All;
                Caption = 'Projekt Nr.';
            }
        }
    }

    actions
    {
        addafter(Dimensions)
        {
            action(Restore)
            {
                ApplicationArea = Suite;
                Caption = '&Restore';
                Ellipsis = true;
                Image = Restore;
                ToolTip = 'Transfer the contents of this archived version to the original document. This is only possible if the original is not posted or deleted. ';

                trigger OnAction()
                var
                    ArchiveManagement: Codeunit ArchiveManagement;
                    PurchaseArchiveCU: Codeunit PurchaseArchiveCU;
                begin
                    PurchaseArchiveCU.RestorePurchaseDocument(Rec);
                end;
            }
        }
    }

    var
        myInt: Integer;
}