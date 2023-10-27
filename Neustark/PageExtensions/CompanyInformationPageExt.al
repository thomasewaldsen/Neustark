pageextension 50109 CompanyInformationPageExt extends "Company Information"
{
    layout
    {
        addafter("Country/Region Code")
        {
            field("Language Code"; Rec."Sen Language Code")
            {
                ApplicationArea = All;
            }
        }
    }
}