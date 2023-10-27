codeunit 50100 PurchaseOrderCU
{
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post Prepmt. (Yes/No)", 'OnAfterPostPrepmtInvoiceYN', '', false, false)]
    // local procedure OnAfterPostPrepmtInvoiceYN(var PurchaseHeader: Record "Purchase Header")
    // begin
    //     if PurchaseHeader."Prepayment %" <> 0 then
    //         PurchaseHeader.ProcessStatus := ProcessStatusEnum::vorausbezahlt;
    // end;


    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeSendRecords', '', false, false)]
    local procedure OnBeforeSendRecords(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        if (PurchaseHeader."Prepayment %" <> 0) and (PurchaseHeader.ProcessStatus <> ProcessStatusEnum::vorausbezahlt) then begin
            PurchaseHeader.ProcessStatus := ProcessStatusEnum::vorauszuzahlen;
            PurchaseHeader.Modify();
        end
        else begin
            PurchaseHeader.ProcessStatus := ProcessStatusEnum::bestellt;
            PurchaseHeader.Modify();
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post Prepmt. (Yes/No)", 'OnBeforePostPrepmtDocument', '', false, false)]
    local procedure OnBeforePostPrepmtDocument(var PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Prepayment %" <> 0 then begin
            PurchaseHeader.ProcessStatus := ProcessStatusEnum::vorausbezahlt;
            PurchaseHeader.Modify();
        end;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostInvoice', '', false, false)]
    // local procedure OnBeforePostInvoice(var PurchHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean; var Window: Dialog; HideProgressWindow: Boolean; var TotalPurchLine: Record "Purchase Line"; var TotalPurchLineLCY: Record "Purchase Line"; var InvoicePostingInterface: Interface "Invoice Posting"; var InvoicePostingParameters: Record "Invoice Posting Parameters"; GenJnlLineDocNo: Code[20]; GenJnlLineExtDocNo: Code[35]; GenJnlLineDocType: Enum "Gen. Journal Document Type"; SrcCode: Code[10])
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRunOnBeforePostPurchLine', '', false, false)]
    local procedure OnRunOnBeforePostPurchLine(var PurchLine: Record "Purchase Line"; var PurchHeader: Record "Purchase Header")
    var
        PurchaseLinesRec: Record "Purchase Line";
        PurchaseLineType: Enum "Purchase Line Type";
        GeneralPostingSetupRec: Record "General Posting Setup";
        IsAllDelivered: Boolean;
        IsPartiallyDelivered: Boolean;
        QtyReceived: Integer;
        QtyTotal: Integer;
    begin
        PurchaseLinesRec.SetRange("Document No.", PurchHeader."No.");
        if PurchaseLinesRec.FindSet() then
            repeat
                if PurchaseLinesRec.Type = PurchaseLineType::"G/L Account" then begin
                    GeneralPostingSetupRec.SetRange("Gen. Bus. Posting Group", PurchHeader."Gen. Bus. Posting Group");
                    GeneralPostingSetupRec.SetRange("Purch. Prepayments Account", PurchaseLinesRec."No.");

                    if GeneralPostingSetupRec.FindSet() then begin
                        PurchHeader.ProcessStatus := ProcessStatusEnum::vorausbezahlt;
                        PurchHeader.Modify();
                    end;
                end;
            until PurchaseLinesRec.Next() = 0;

        IsAllDelivered := true;
        IsPartiallyDelivered := true;

        //check if ALL Delivered
        if PurchaseLinesRec.FindSet() then
            repeat
                QtyTotal += PurchaseLinesRec.Quantity;
                QtyReceived += PurchaseLinesRec."Qty. to Invoice";
            until PurchaseLinesRec.Next() = 0;

        if QtyReceived = QtyTotal then begin
            PurchHeader.ProcessStatus := ProcessStatusEnum::geliefert;
            PurchHeader.Modify()
        end
        else
            if (QtyReceived <> QtyTotal) and (QtyReceived > 0) then begin
                PurchHeader.ProcessStatus := ProcessStatusEnum::"teilweise geliefert";
                PurchHeader.Modify();
            end;
    end;
}