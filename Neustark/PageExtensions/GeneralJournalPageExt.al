pageextension 50108 GeneralJournalPageExt extends "General Journal"
{
    layout
    {
        addafter("Document No.")
        {
            field("Job No."; Rec."Job No.")
            {
                ApplicationArea = All;
            }
            field("Job Task No."; Rec."Job Task No.")
            {
                ApplicationArea = All;
            }
            field("Job Quantity"; Rec."Job Quantity")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}